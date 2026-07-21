package hearts

import (
	"context"
	"fmt"
	"strconv"

	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
)

const (
	maxHearts    = 5
	heartsKeyFmt = "user:%d:hearts" // Redis key format
)

// Service handles hearts operations with Redis cache-aside + write-behind.
type Service struct {
	db  *sqlx.DB
	rdb *redis.Client
}

// NewService creates a new hearts service.
func NewService(db *sqlx.DB, rdb *redis.Client) *Service {
	return &Service{db: db, rdb: rdb}
}

// GetHearts returns the current hearts count.
// Cache-Aside: Redis first → PostgreSQL fallback → warm cache.
func (s *Service) GetHearts(userID int64) (int, error) {
	ctx := context.Background()
	key := fmt.Sprintf(heartsKeyFmt, userID)

	// Try Redis first
	if s.rdb != nil {
		val, err := s.rdb.Get(ctx, key).Int()
		if err == nil {
			return val, nil
		}
		// If not redis.Nil, log but continue to DB
	}

	// Fallback to PostgreSQL
	var hearts int
	err := s.db.Get(&hearts, "SELECT hearts FROM users WHERE id = $1", userID)
	if err != nil {
		return maxHearts, fmt.Errorf("get hearts from db: %w", err)
	}

	// Warm Redis cache
	if s.rdb != nil {
		s.rdb.Set(ctx, key, hearts, 0) // No expiry — write-behind keeps it in sync
	}

	return hearts, nil
}

// DecrementHearts atomically decrements hearts in Redis and syncs to DB.
// Returns new hearts count. Floor at 0.
func (s *Service) DecrementHearts(userID int64, amount int) (int, error) {
	ctx := context.Background()
	key := fmt.Sprintf(heartsKeyFmt, userID)

	if s.rdb != nil {
		// Ensure key exists in Redis
		exists, _ := s.rdb.Exists(ctx, key).Result()
		if exists == 0 {
			// Warm from DB first
			current, err := s.getHeartsFromDB(userID)
			if err != nil {
				return 0, err
			}
			s.rdb.Set(ctx, key, current, 0)
		}

		// Atomic decrement
		newVal, err := s.rdb.DecrBy(ctx, key, int64(amount)).Result()
		if err != nil {
			return 0, fmt.Errorf("redis decrby: %w", err)
		}

		// Floor at 0
		if newVal < 0 {
			s.rdb.Set(ctx, key, 0, 0)
			newVal = 0
		}

		// Write-behind: sync to DB in background goroutine
		go s.syncHeartsToDB(userID, int(newVal))

		return int(newVal), nil
	}

	// No Redis — direct DB update
	return s.decrementHeartsDB(userID, amount)
}

// IncrementHearts atomically increments hearts in Redis and syncs to DB.
// Returns new hearts count. Cap at maxHearts.
func (s *Service) IncrementHearts(userID int64, amount int) (int, error) {
	ctx := context.Background()
	key := fmt.Sprintf(heartsKeyFmt, userID)

	if s.rdb != nil {
		// Ensure key exists in Redis
		exists, _ := s.rdb.Exists(ctx, key).Result()
		if exists == 0 {
			current, err := s.getHeartsFromDB(userID)
			if err != nil {
				return 0, err
			}
			s.rdb.Set(ctx, key, current, 0)
		}

		// Atomic increment
		newVal, err := s.rdb.IncrBy(ctx, key, int64(amount)).Result()
		if err != nil {
			return 0, fmt.Errorf("redis incrby: %w", err)
		}

		// Cap at maxHearts
		if newVal > int64(maxHearts) {
			s.rdb.Set(ctx, key, maxHearts, 0)
			newVal = int64(maxHearts)
		}

		// Write-behind: sync to DB in background goroutine
		go s.syncHeartsToDB(userID, int(newVal))

		return int(newVal), nil
	}

	// No Redis — direct DB update
	return s.incrementHeartsDB(userID, amount)
}

func (s *Service) getHeartsFromDB(userID int64) (int, error) {
	var hearts int
	err := s.db.Get(&hearts, "SELECT hearts FROM users WHERE id = $1", userID)
	if err != nil {
		return maxHearts, fmt.Errorf("get hearts: %w", err)
	}
	return hearts, nil
}

func (s *Service) syncHeartsToDB(userID int64, hearts int) {
	_, _ = s.db.Exec("UPDATE users SET hearts = $1, updated_at = NOW() WHERE id = $2", hearts, userID)
}

func (s *Service) decrementHeartsDB(userID int64, amount int) (int, error) {
	var newHearts int
	err := s.db.Get(&newHearts,
		`UPDATE users SET hearts = GREATEST(hearts - $1, 0), updated_at = NOW()
		 WHERE id = $2 RETURNING hearts`, amount, userID)
	if err != nil {
		return 0, fmt.Errorf("decrement hearts db: %w", err)
	}
	return newHearts, nil
}

func (s *Service) incrementHeartsDB(userID int64, amount int) (int, error) {
	var newHearts int
	err := s.db.Get(&newHearts,
		`UPDATE users SET hearts = LEAST(hearts + $1, $2), updated_at = NOW()
		 WHERE id = $3 RETURNING hearts`, amount, maxHearts, userID)
	if err != nil {
		return 0, fmt.Errorf("increment hearts db: %w", err)
	}
	return newHearts, nil
}

// InvalidateCache removes the cached hearts value for a user.
func (s *Service) InvalidateCache(userID int64) {
	if s.rdb == nil {
		return
	}
	key := fmt.Sprintf(heartsKeyFmt, userID)
	s.rdb.Del(context.Background(), key)
}

// UserIDFromString parses a string user ID (for URL params).
func UserIDFromString(s string) (int64, error) {
	return strconv.ParseInt(s, 10, 64)
}
