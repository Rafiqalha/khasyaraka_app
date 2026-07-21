package auth

import (
	"database/sql"
	"fmt"

	"github.com/jmoiron/sqlx"
)

type User struct {
	ID                 int64          `db:"id"`
	FullName           sql.NullString `db:"full_name"`
	Email              string         `db:"email"`
	HashedPassword     string         `db:"hashed_password"`
	PictureURL         *string        `db:"picture_url"`
	TotalXP            int            `db:"total_xp"`
	Streak             int            `db:"streak"`
	Hearts             int            `db:"hearts"`
	IsActive           bool           `db:"is_active"`
	IsSuperuser        bool           `db:"is_superuser"`
	MustChangePassword bool           `db:"must_change_password"`
	CountryID          sql.NullString `db:"country_id"`
	ProvinsiID         sql.NullString `db:"provinsi_id"`
	KabupatenID        sql.NullString `db:"kabupaten_id"`
	KecamatanID        sql.NullString `db:"kecamatan_id"`
}

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) GetByEmail(email string) (*User, error) {
	var u User
	err := r.db.Get(&u, "SELECT id, full_name, email, hashed_password, picture_url, total_xp, streak, hearts, is_active, is_superuser, must_change_password FROM users WHERE email = $1", email)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get user by email: %w", err)
	}
	return &u, nil
}

func (r *Repository) GetByID(id int64) (*User, error) {
	var u User
	err := r.db.Get(&u, "SELECT id, full_name, email, hashed_password, picture_url, total_xp, streak, hearts, is_active, is_superuser, must_change_password FROM users WHERE id = $1", id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get user by id: %w", err)
	}
	return &u, nil
}

func (r *Repository) Create(email, hashedPassword, fullName string, pictureURL *string, isActive bool, countryID, provinsiID, kabupatenID, kecamatanID string) (*User, error) {
	countryIDVal := toNullString(countryID)
	provinsiIDVal := toNullString(provinsiID)
	kabupatenIDVal := toNullString(kabupatenID)
	kecamatanIDVal := toNullString(kecamatanID)
	locationSet := countryID != "" && provinsiID != "" && kabupatenID != "" && kecamatanID != ""

	var id int64
	err := r.db.QueryRow(
		`INSERT INTO users (email, hashed_password, full_name, picture_url, is_active, country_id, provinsi_id, kabupaten_id, kecamatan_id, location_set)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id`,
		email, hashedPassword, fullName, pictureURL, isActive, countryIDVal, provinsiIDVal, kabupatenIDVal, kecamatanIDVal, locationSet,
	).Scan(&id)
	if err != nil {
		return nil, fmt.Errorf("create user: %w", err)
	}
	return r.GetByID(id)
}

func toNullString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{Valid: false}
	}
	return sql.NullString{String: s, Valid: true}
}

func (r *Repository) UpdatePictureURL(userID int64, pictureURL string) error {
	_, err := r.db.Exec("UPDATE users SET picture_url = $1 WHERE id = $2", pictureURL, userID)
	return err
}

func (r *Repository) UpdatePassword(userID int64, hashedPassword string) error {
	_, err := r.db.Exec(
		"UPDATE users SET hashed_password = $1, must_change_password = FALSE, updated_at = NOW() WHERE id = $2",
		hashedPassword, userID,
	)
	return err
}
