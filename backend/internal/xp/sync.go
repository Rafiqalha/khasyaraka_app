package xp

import (
	"context"
	"strconv"

	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
)

const leaderboardKey = "leaderboard:xp"

func SyncToRedis(db *sqlx.DB, rdb *redis.Client, userID int64) error {
	var totalXP int
	if err := db.Get(&totalXP, "SELECT total_xp FROM users WHERE id = $1", userID); err != nil {
		return err
	}
	return rdb.ZAdd(context.Background(), leaderboardKey, redis.Z{
		Score:  float64(totalXP),
		Member: strconv.FormatInt(userID, 10),
	}).Err()
}
