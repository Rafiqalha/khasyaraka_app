// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package survival

import (
	"database/sql"
	"fmt"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) GetByUserAndTool(userID int64, toolType string) (*Mastery, error) {
	var m Mastery
	err := r.db.Get(&m, `SELECT id, user_id, tool_type, current_xp, current_level,
		total_actions, highest_streak, max_altitude, total_distance_tracked
		FROM survival_mastery WHERE user_id = $1 AND tool_type = $2`, userID, toolType)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get mastery: %w", err)
	}
	return &m, nil
}

func (r *Repository) GetByUser(userID int64) ([]Mastery, error) {
	var list []Mastery
	err := r.db.Select(&list, `SELECT id, user_id, tool_type, current_xp, current_level,
		total_actions, highest_streak, max_altitude, total_distance_tracked
		FROM survival_mastery WHERE user_id = $1 ORDER BY tool_type`, userID)
	if err != nil {
		return nil, fmt.Errorf("get user mastery: %w", err)
	}
	return list, nil
}

func (r *Repository) UpsertAction(userID int64, toolType string, distance, altitude float64, isStreak bool) error {
	existing, _ := r.GetByUserAndTool(userID, toolType)

	if existing != nil {
		xpGain := 5
		streak := existing.HighestStreak
		if isStreak {
			xpGain = 10
			streak++
		}
		newLevel := existing.CurrentLevel
		newXP := existing.CurrentXP + xpGain
		if newXP >= newLevel*100 {
			newLevel++
			newXP = 0
		}
		newAlt := existing.MaxAltitude
		if altitude > newAlt {
			newAlt = altitude
		}

		_, err := r.db.Exec(`
			UPDATE survival_mastery SET current_xp = $1, current_level = $2,
			total_actions = total_actions + 1, highest_streak = GREATEST(highest_streak, $3),
			max_altitude = GREATEST(max_altitude, $4), total_distance_tracked = total_distance_tracked + $5,
			updated_at = NOW() WHERE id = $6
		`, newXP, newLevel, streak, altitude, distance, existing.ID)
		return err
	}

	_, err := r.db.Exec(`
		INSERT INTO survival_mastery (user_id, tool_type, current_xp, current_level, total_actions,
			highest_streak, max_altitude, total_distance_tracked)
		VALUES ($1, $2, $3, $4, 1, $5, $6, $7)
	`, userID, toolType, 5, 1, 0, altitude, distance)
	return err
}

func (r *Repository) GetLeaderboard(limit int) ([]LeaderboardEntry, error) {
	var entries []LeaderboardEntry
	err := r.db.Select(&entries, `
		SELECT sm.user_id, COALESCE(u.full_name, u.email) AS full_name, u.total_xp, sm.tool_type, sm.current_level AS level
		FROM survival_mastery sm
		JOIN users u ON u.id = sm.user_id
		ORDER BY sm.current_level DESC, sm.current_xp DESC
		LIMIT $1`, limit)
	if err != nil {
		return nil, fmt.Errorf("get survival leaderboard: %w", err)
	}
	return entries, nil
}
