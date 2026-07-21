package xp

import (
	"context"
	"database/sql"
	"strconv"

	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
)

const (
	keyGlobal  = "leaderboard:xp:global"
	keyCountry = "leaderboard:xp:country:"
	keyProv    = "leaderboard:xp:prov:"
	keyCity    = "leaderboard:xp:city:"
	keyDist    = "leaderboard:xp:dist:"
)

type userLocation struct {
	CountryID   sql.NullString `db:"country_id"`
	ProvinsiID  sql.NullString `db:"provinsi_id"`
	KabupatenID sql.NullString `db:"kabupaten_id"`
	KecamatanID sql.NullString `db:"kecamatan_id"`
}

func SyncToRedis(db *sqlx.DB, rdb *redis.Client, userID int64) error {
	var totalXP int
	if err := db.Get(&totalXP, "SELECT total_xp FROM users WHERE id = $1", userID); err != nil {
		return err
	}

	var loc userLocation
	err := db.Get(&loc, "SELECT country_id, provinsi_id, kabupaten_id, kecamatan_id FROM users WHERE id = $1", userID)
	if err != nil && err != sql.ErrNoRows {
		return err
	}

	ctx := context.Background()
	pipe := rdb.TxPipeline()

	member := strconv.FormatInt(userID, 10)
	score := float64(totalXP)
	z := redis.Z{Score: score, Member: member}

	pipe.ZAdd(ctx, keyGlobal, z)

	if loc.CountryID.Valid && loc.CountryID.String != "" {
		pipe.ZAdd(ctx, keyCountry+loc.CountryID.String, z)
	}
	if loc.ProvinsiID.Valid && loc.ProvinsiID.String != "" {
		pipe.ZAdd(ctx, keyProv+loc.ProvinsiID.String, z)
	}
	if loc.KabupatenID.Valid && loc.KabupatenID.String != "" {
		pipe.ZAdd(ctx, keyCity+loc.KabupatenID.String, z)
	}
	if loc.KecamatanID.Valid && loc.KecamatanID.String != "" {
		pipe.ZAdd(ctx, keyDist+loc.KecamatanID.String, z)
	}

	_, err = pipe.Exec(ctx)
	return err
}
