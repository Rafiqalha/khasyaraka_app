package leaderboard

import (
	"context"
	"database/sql"
	"fmt"
	"strconv"

	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
)

type userRow struct {
	ID          int64          `db:"id"`
	FullName    string         `db:"full_name"`
	TotalXP     int            `db:"total_xp"`
	HackLevel   string         `db:"hack_level"`
	CountryID   sql.NullString `db:"country_id"`
	ProvinsiID  sql.NullString `db:"provinsi_id"`
	KabupatenID sql.NullString `db:"kabupaten_id"`
	KecamatanID sql.NullString `db:"kecamatan_id"`
}

type Repository struct {
	db  *sqlx.DB
	rdb *redis.Client
}

func NewRepository(db *sqlx.DB, rdb *redis.Client) *Repository {
	return &Repository{db: db, rdb: rdb}
}

// getRedisKey constructs the dynamic redis key: leaderboard:[KATEGORI]:[WILAYAH_ID]
func getRedisKey(category string, scope string, locationID string) string {
	if category == "" {
		category = "rank"
	}
	if scope == "global" || scope == "nasional" {
		return fmt.Sprintf("leaderboard:%s:global", category)
	}
	if (scope == "country" || scope == "negara") && locationID != "" {
		return fmt.Sprintf("leaderboard:%s:country:%s", category, locationID)
	}
	if (scope == "province" || scope == "provinsi") && locationID != "" {
		return fmt.Sprintf("leaderboard:%s:prov:%s", category, locationID)
	}
	if (scope == "city" || scope == "kota") && locationID != "" {
		return fmt.Sprintf("leaderboard:%s:city:%s", category, locationID)
	}
	if (scope == "district" || scope == "kecamatan") && locationID != "" {
		return fmt.Sprintf("leaderboard:%s:dist:%s", category, locationID)
	}
	return fmt.Sprintf("leaderboard:%s:global", category)
}

// SyncScore pushes the user's new score to all 3 scopes simultaneously.
func (r *Repository) SyncScore(userID int64, category string, score float64) error {
	// First, fetch the user's location
	var u userRow
	err := r.db.Get(&u, "SELECT id, provinsi_id, kabupaten_id, kecamatan_id, country_id FROM users WHERE id = $1", userID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil
		}
		return err
	}

	ctx := context.Background()
	pipe := r.rdb.TxPipeline()

	member := strconv.FormatInt(userID, 10)
	z := redis.Z{Score: score, Member: member}

	// 1. Global
	pipe.ZAdd(ctx, getRedisKey(category, "global", ""), z)

	// 2. Country
	if u.CountryID.Valid && u.CountryID.String != "" {
		pipe.ZAdd(ctx, getRedisKey(category, "country", u.CountryID.String), z)
	}

	// 3. Provinsi
	if u.ProvinsiID.Valid && u.ProvinsiID.String != "" {
		pipe.ZAdd(ctx, getRedisKey(category, "provinsi", u.ProvinsiID.String), z)
	}

	// 4. Kota / Kabupaten
	if u.KabupatenID.Valid && u.KabupatenID.String != "" {
		pipe.ZAdd(ctx, getRedisKey(category, "kota", u.KabupatenID.String), z)
	}

	// 5. Kecamatan
	if u.KecamatanID.Valid && u.KecamatanID.String != "" {
		pipe.ZAdd(ctx, getRedisKey(category, "kecamatan", u.KecamatanID.String), z)
	}

	_, err = pipe.Exec(ctx)
	return err
}

func (r *Repository) GetTop(category string, scope string, locationID string, limit int) ([]Entry, error) {
	key := getRedisKey(category, scope, locationID)
	
	results, err := r.rdb.ZRevRangeWithScores(context.Background(), key, 0, int64(limit-1)).Result()
	if err != nil {
		return nil, fmt.Errorf("redis zrevrange: %w", err)
	}

	if len(results) == 0 {
		return []Entry{}, nil
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
		q, args, _ := sqlx.In("SELECT id, COALESCE(full_name, email) AS full_name, total_xp, hack_level, country_id, provinsi_id, kabupaten_id, kecamatan_id FROM users WHERE id IN (?)", userIDs)
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
		
		// For rank calculation, we assume total_xp is total stars. 
		// If category != rank, we might need a different calculator, but we'll use CalculateRank for all for now or just for rank.
		var totalStars int
		if category == "rank" || category == "" {
			totalStars = int(results[rank].Score) // The actual ZSET score
		} else {
			totalStars = u.TotalXP // Fallback or if total_xp is used differently
		}
		
		countryID := ""
		if u.CountryID.Valid {
			countryID = u.CountryID.String
		}
		provId := ""
		if u.ProvinsiID.Valid {
			provId = u.ProvinsiID.String
		}
		kotaId := ""
		if u.KabupatenID.Valid {
			kotaId = u.KabupatenID.String
		}
		kecId := ""
		if u.KecamatanID.Valid {
			kecId = u.KecamatanID.String
		}

		entries = append(entries, Entry{
			Rank:        rank + 1,
			UserID:      u.ID,
			FullName:    u.FullName,
			TotalXP:     int(results[rank].Score),
			HackLevel:   u.HackLevel,
			CountryID:   countryID,
			ProvinsiID:  provId,
			KabupatenID: kotaId,
			KecamatanID: kecId,
			RankInfo:    CalculateRank(totalStars),
		})
	}
	return entries, nil
}

func (r *Repository) GetUserRank(userID int64, category string, scope string, locationID string) (*UserRank, error) {
	key := getRedisKey(category, scope, locationID)
	uidStr := strconv.FormatInt(userID, 10)
	
	rank, err := r.rdb.ZRevRank(context.Background(), key, uidStr).Result()
	if err == redis.Nil {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("redis zrevrank: %w", err)
	}

	score, err := r.rdb.ZScore(context.Background(), key, uidStr).Result()
	if err != nil {
		return nil, fmt.Errorf("redis zscore: %w", err)
	}

	total, err := r.rdb.ZCard(context.Background(), key).Result()
	if err != nil {
		return nil, fmt.Errorf("redis zcard: %w", err)
	}

	var totalStars int
	if category == "rank" || category == "" {
		totalStars = int(score)
	}

	return &UserRank{
		Rank:     int(rank) + 1,
		TotalXP:  int(score),
		TopCount: int(total),
		RankInfo: CalculateRank(totalStars),
	}, nil
}
