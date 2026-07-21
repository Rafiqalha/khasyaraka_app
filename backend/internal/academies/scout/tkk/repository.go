package tkk

import (
	"fmt"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) GetByUser(userID int64) ([]TKKBadge, error) {
	var badges []TKKBadge
	err := r.db.Select(&badges, "SELECT id, user_id, tkk_slug, level, attained_at FROM user_tkk WHERE user_id = $1 ORDER BY attained_at DESC", userID)
	if err != nil {
		return nil, fmt.Errorf("get tkk badges: %w", err)
	}
	return badges, nil
}

func (r *Repository) Create(userID int64, slug, level string) (*TKKBadge, error) {
	var b TKKBadge
	err := r.db.QueryRowx(
		"INSERT INTO user_tkk (user_id, tkk_slug, level) VALUES ($1, $2, $3) RETURNING id, user_id, tkk_slug, level, attained_at",
		userID, slug, level,
	).StructScan(&b)
	if err != nil {
		return nil, fmt.Errorf("attain tkk: %w", err)
	}
	return &b, nil
}

func (r *Repository) Exists(userID int64, slug, level string) (bool, error) {
	var count int
	err := r.db.Get(&count, "SELECT COUNT(*) FROM user_tkk WHERE user_id = $1 AND tkk_slug = $2 AND level = $3", userID, slug, level)
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
