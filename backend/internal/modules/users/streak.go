package users

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

// StreakResult holds the outcome of an atomic streak update.
type StreakResult struct {
	Streak         int    `json:"streak"`
	LongestStreak  int    `json:"longest_streak"`
	LastActiveDate string `json:"last_active_date"`
	AlreadyCounted bool   `json:"already_counted"`
}

// UpdateStreakAtomic atomically updates a user's daily streak after a lesson
// completion.  It uses a SELECT … FOR UPDATE row-level lock to prevent
// concurrent requests from double-incrementing.
//
// Rules:
//   - Max 1 increment per calendar day (user's timezone)
//   - Resets to 1 if user misses 1+ full days
//   - Tracks both current streak and longest streak
func UpdateStreakAtomic(db *sqlx.DB, userID int64, userTimezone string) (*StreakResult, error) {
	if userTimezone == "" {
		userTimezone = "Asia/Jakarta"
	}

	loc, err := time.LoadLocation(userTimezone)
	if err != nil {
		loc, _ = time.LoadLocation("Asia/Jakarta")
	}

	todayUser := time.Now().In(loc).Format("2006-01-02")

	// Begin transaction
	tx, err := db.Beginx()
	if err != nil {
		return nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback() //nolint:errcheck

	// Lock the user row
	var streak, longestStreak int
	var lastActive sql.NullString
	err = tx.QueryRow(
		`SELECT streak, longest_streak, last_active_date
		 FROM users WHERE id = $1 FOR UPDATE`, userID,
	).Scan(&streak, &longestStreak, &lastActive)
	if err != nil {
		if err == sql.ErrNoRows {
			return &StreakResult{}, nil
		}
		return nil, fmt.Errorf("lock user row: %w", err)
	}

	alreadyCounted := false
	newStreak := 1

	if !lastActive.Valid {
		// First ever lesson completion
		newStreak = 1
	} else {
		lastActiveStr := lastActive.String
		if len(lastActiveStr) > 10 {
			lastActiveStr = lastActiveStr[:10]
		}

		if lastActiveStr == todayUser {
			// Already completed a lesson today — no change
			newStreak = streak
			alreadyCounted = true
		} else {
			// Parse last active date to check if it was yesterday
			lastDate, err := time.ParseInLocation("2006-01-02", lastActiveStr, loc)
			if err != nil {
				// Can't parse — treat as reset
				newStreak = 1
			} else {
				todayDate, _ := time.ParseInLocation("2006-01-02", todayUser, loc)
				diff := todayDate.Sub(lastDate).Hours() / 24
				if diff >= 0.5 && diff < 1.5 {
					// Active yesterday — continue streak
					newStreak = streak + 1
				} else {
					// Missed 1+ full days — reset to 1
					newStreak = 1
				}
			}
		}
	}

	// Update longest streak
	newLongest := longestStreak
	if newStreak > newLongest {
		newLongest = newStreak
	}

	// Write back (still under FOR UPDATE lock)
	_, err = tx.Exec(
		`UPDATE users SET streak = $1, longest_streak = $2, last_active_date = $3, updated_at = NOW()
		 WHERE id = $4`,
		newStreak, newLongest, todayUser, userID,
	)
	if err != nil {
		return nil, fmt.Errorf("update streak: %w", err)
	}

	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("commit streak tx: %w", err)
	}

	return &StreakResult{
		Streak:         newStreak,
		LongestStreak:  newLongest,
		LastActiveDate: todayUser,
		AlreadyCounted: alreadyCounted,
	}, nil
}
