package leaderboard

import (
	"context"
	"fmt"
	"strconv"

	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
)

const leaderboardKey = "leaderboard:xp"

type userRow struct {
	ID        int64  `db:"id"`
	FullName  string `db:"full_name"`
	TotalXP   int    `db:"total_xp"`
	HackLevel string `db:"hack_level"`
}

type Repository struct {
	db  *sqlx.DB
	rdb *redis.Client
}

func NewRepository(db *sqlx.DB, rdb *redis.Client) *Repository {
	return &Repository{db: db, rdb: rdb}
}

func (r *Repository) SyncUserXP(userID int64, totalXP int) error {
	return r.rdb.ZAdd(context.Background(), leaderboardKey, redis.Z{
		Score:  float64(totalXP),
		Member: strconv.FormatInt(userID, 10),
	}).Err()
}

func (r *Repository) GetTop(limit int) ([]Entry, error) {
	results, err := r.rdb.ZRevRangeWithScores(context.Background(), leaderboardKey, 0, int64(limit-1)).Result()
	if err != nil {
		return nil, fmt.Errorf("redis zrevrange: %w", err)
	}

	// Cold start fallback: if Redis is empty, load from PostgreSQL and warm cache
	if len(results) == 0 {
		return r.getTopFromDBAndWarm(limit)
	}

	var entries []Entry
	userIDs := make([]int64, 0, len(results))
	for _, z := range results {
		uidStr, ok := z.Member.(string)
		if !ok {
			continue
		}
		uid, err := strconv.ParseInt(uidStr, 10, 64)
		if err != nil {
			continue
		}
		userIDs = append(userIDs, uid)
	}

	var users []userRow
	if len(userIDs) > 0 {
		q, args, _ := sqlx.In("SELECT id, COALESCE(full_name, email) AS full_name, total_xp, hack_level FROM users WHERE id IN (?) ORDER BY total_xp DESC", userIDs)
		q = r.db.Rebind(q)
		if err := r.db.Select(&users, q, args...); err != nil {
			return nil, fmt.Errorf("get users: %w", err)
		}
	}

	userMap := make(map[int64]userRow)
	for _, u := range users {
		userMap[u.ID] = u
	}

	for rank, uid := range userIDs {
		u, ok := userMap[uid]
		if !ok {
			continue
		}
		entries = append(entries, Entry{
			Rank:      rank + 1,
			UserID:    u.ID,
			FullName:  u.FullName,
			TotalXP:   u.TotalXP,
			HackLevel: u.HackLevel,
		})
	}
	return entries, nil
}

// getTopFromDBAndWarm queries PostgreSQL for top users and warms the Redis cache.
// This is the cold-start fallback when Redis has no leaderboard data.
func (r *Repository) getTopFromDBAndWarm(limit int) ([]Entry, error) {
	var users []userRow
	err := r.db.Select(&users,
		`SELECT id, COALESCE(full_name, email) AS full_name, total_xp, hack_level
		 FROM users WHERE is_active = TRUE AND total_xp > 0
		 ORDER BY total_xp DESC LIMIT $1`, limit)
	if err != nil {
		return nil, fmt.Errorf("get top from db: %w", err)
	}

	// Warm Redis cache with all active users (not just top N)
	go r.warmCacheFromDB()

	entries := make([]Entry, 0, len(users))
	for rank, u := range users {
		entries = append(entries, Entry{
			Rank:      rank + 1,
			UserID:    u.ID,
			FullName:  u.FullName,
			TotalXP:   u.TotalXP,
			HackLevel: u.HackLevel,
		})
	}
	return entries, nil
}

// warmCacheFromDB loads all users with XP into the Redis ZSET.
func (r *Repository) warmCacheFromDB() {
	var users []struct {
		ID      int64 `db:"id"`
		TotalXP int   `db:"total_xp"`
	}
	if err := r.db.Select(&users, "SELECT id, total_xp FROM users WHERE is_active = TRUE AND total_xp > 0"); err != nil {
		return
	}

	ctx := context.Background()
	members := make([]redis.Z, 0, len(users))
	for _, u := range users {
		members = append(members, redis.Z{
			Score:  float64(u.TotalXP),
			Member: strconv.FormatInt(u.ID, 10),
		})
	}

	if len(members) > 0 {
		r.rdb.ZAdd(ctx, leaderboardKey, members...)
	}
}

func (r *Repository) GetUserRank(userID int64) (*UserRank, error) {
	uidStr := strconv.FormatInt(userID, 10)
	rank, err := r.rdb.ZRevRank(context.Background(), leaderboardKey, uidStr).Result()
	if err == redis.Nil {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("redis zrevrank: %w", err)
	}

	score, err := r.rdb.ZScore(context.Background(), leaderboardKey, uidStr).Result()
	if err != nil {
		return nil, fmt.Errorf("redis zscore: %w", err)
	}

	total, err := r.rdb.ZCard(context.Background(), leaderboardKey).Result()
	if err != nil {
		return nil, fmt.Errorf("redis zcard: %w", err)
	}

	return &UserRank{
		Rank:     int(rank) + 1,
		TotalXP:  int(score),
		TopCount: int(total),
	}, nil
}
