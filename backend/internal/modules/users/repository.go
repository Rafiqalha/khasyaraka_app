package users

import (
	"database/sql"
	"fmt"
	"strings"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) GetByID(id int64) (*Profile, error) {
	var p Profile
	err := r.db.Get(&p, `SELECT id, full_name, email, picture_url, total_xp, hack_level,
		decrypted_count, streak, longest_streak, hearts, last_active_date, timezone,
		is_superuser, created_at, updated_at
		FROM users WHERE id = $1`, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get user by id: %w", err)
	}
	return &p, nil
}

func (r *Repository) UpdateProfile(id int64, fullName, timezone *string) error {
	var sets []string
	args := []interface{}{}
	argIdx := 1

	if fullName != nil {
		sets = append(sets, fmt.Sprintf("full_name = $%d", argIdx))
		args = append(args, *fullName)
		argIdx++
	}
	if timezone != nil {
		sets = append(sets, fmt.Sprintf("timezone = $%d", argIdx))
		args = append(args, *timezone)
		argIdx++
	}
	if len(sets) == 0 {
		return nil
	}

	sets = append(sets, "updated_at = NOW()")
	args = append(args, id)
	q := fmt.Sprintf("UPDATE users SET %s WHERE id = $%d", strings.Join(sets, ", "), argIdx)

	_, err := r.db.Exec(q, args...)
	return err
}

func (r *Repository) UpdatePictureURL(id int64, url string) error {
	_, err := r.db.Exec("UPDATE users SET picture_url = $1, updated_at = NOW() WHERE id = $2", url, id)
	return err
}
