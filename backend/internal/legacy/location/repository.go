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

func (r *Repository) GetCountries() ([]CountryOption, error) {
	var countries []CountryOption
	err := r.db.Select(&countries, "SELECT id, name, code FROM countries ORDER BY name")
	if err != nil {
		return nil, fmt.Errorf("get countries: %w", err)
	}
	return countries, nil
}

func (r *Repository) GetProvincesByCountry(countryID string) ([]ProvinsiOption, error) {
	var provs []ProvinsiOption
	err := r.db.Select(&provs, "SELECT id, name FROM provinces WHERE country_id = $1 ORDER BY name", countryID)
	if err != nil {
		return nil, fmt.Errorf("get provinces by country: %w", err)
	}
	return provs, nil
}

func (r *Repository) GetRegenciesByProvince(provinceID string) ([]KabupatenOption, error) {
	var regs []KabupatenOption
	err := r.db.Select(&regs, "SELECT id, name FROM regencies WHERE province_id = $1 ORDER BY name", provinceID)
	if err != nil {
		return nil, fmt.Errorf("get regencies by province: %w", err)
	}
	return regs, nil
}

func (r *Repository) GetDistrictsByRegency(regencyID string) ([]KecamatanOption, error) {
	var dists []KecamatanOption
	err := r.db.Select(&dists, "SELECT id, name FROM districts WHERE regency_id = $1 ORDER BY name", regencyID)
	if err != nil {
		return nil, fmt.Errorf("get districts by regency: %w", err)
	}
	return dists, nil
}

func (r *Repository) GetDistrictByID(districtID string) (*KecamatanOption, error) {
	var d KecamatanOption
	err := r.db.Get(&d, "SELECT id, name FROM districts WHERE id = $1", districtID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get district by id: %w", err)
	}
	return &d, nil
}

func (r *Repository) ResolveLocationChain(districtID string) (kecID, kecName, kabID, kabName, provID, provName string, err error) {
	err = r.db.QueryRow(`
		SELECT d.id, d.name, r.id, r.name, p.id, p.name
		FROM districts d
		JOIN regencies r ON r.id = d.regency_id
		JOIN provinces p ON p.id = r.province_id
		WHERE d.id = $1
	`, districtID).Scan(&kecID, &kecName, &kabID, &kabName, &provID, &provName)
	if err != nil {
		if err == sql.ErrNoRows {
			return "", "", "", "", "", "", nil
		}
		return "", "", "", "", "", "", fmt.Errorf("resolve location chain: %w", err)
	}
	return
}

func (r *Repository) GetRegencyByID(regencyID string) (*KabupatenOption, error) {
	var reg KabupatenOption
	err := r.db.Get(&reg, "SELECT id, name FROM regencies WHERE id = $1", regencyID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get regency by id: %w", err)
	}
	return &reg, nil
}

func (r *Repository) GetProvinceByID(provinceID string) (*ProvinsiOption, error) {
	var p ProvinsiOption
	err := r.db.Get(&p, "SELECT id, name FROM provinces WHERE id = $1", provinceID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get province by id: %w", err)
	}
	return &p, nil
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
