package location

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

func (r *Repository) SetUserLocation(userID int64, kecamatanID, kabupatenID, provinsiID string) error {
	_, err := r.db.Exec(`
		UPDATE users 
		SET kecamatan_id = $1, kabupaten_id = $2, provinsi_id = $3, location_set = true
		WHERE id = $4
	`, kecamatanID, kabupatenID, provinsiID, userID)
	return err
}

func (r *Repository) GetUserLocation(userID int64) (*UserLocation, error) {
	var loc UserLocation
	var kec, kab, prov sql.NullString
	
	err := r.db.QueryRow(`
		SELECT kecamatan_id, kabupaten_id, provinsi_id
		FROM users
		WHERE id = $1
	`, userID).Scan(&kec, &kab, &prov)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil // User not found, shouldn't happen if auth works
		}
		return nil, fmt.Errorf("get user location: %w", err)
	}
	
	if !kec.Valid || !kab.Valid || !prov.Valid {
		return nil, nil // Location not set
	}
	
	loc.KecamatanID = kec.String
	loc.KabupatenID = kab.String
	loc.ProvinsiID = prov.String
	return &loc, nil
}
