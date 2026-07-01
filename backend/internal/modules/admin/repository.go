package admin

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

func (r *Repository) ListUsers() ([]map[string]interface{}, error) {
	rows, err := r.db.Queryx("SELECT id, COALESCE(full_name, '') AS full_name, email, total_xp, hack_level, is_active, is_superuser, created_at FROM users ORDER BY id")
	if err != nil {
		return nil, fmt.Errorf("list users: %w", err)
	}
	defer rows.Close()

	var users []map[string]interface{}
	for rows.Next() {
		row := make(map[string]interface{})
		if err := rows.MapScan(row); err != nil {
			return nil, err
		}
		// Convert byte arrays to strings for common fields
		for k, v := range row {
			if b, ok := v.([]byte); ok {
				row[k] = string(b)
			}
		}
		users = append(users, row)
	}
	return users, nil
}

func (r *Repository) UpdateUser(id int64, fullName *string, isActive, isSuperuser *bool, hackLevel, timezone *string) error {
	sets := "updated_at = NOW()"
	args := []interface{}{}
	idx := 1

	if fullName != nil {
		sets += fmt.Sprintf(", full_name = $%d", idx)
		args = append(args, *fullName)
		idx++
	}
	if isActive != nil {
		sets += fmt.Sprintf(", is_active = $%d", idx)
		args = append(args, *isActive)
		idx++
	}
	if isSuperuser != nil {
		sets += fmt.Sprintf(", is_superuser = $%d", idx)
		args = append(args, *isSuperuser)
		idx++
	}
	if hackLevel != nil {
		sets += fmt.Sprintf(", hack_level = $%d", idx)
		args = append(args, *hackLevel)
		idx++
	}
	if timezone != nil {
		sets += fmt.Sprintf(", timezone = $%d", idx)
		args = append(args, *timezone)
		idx++
	}

	args = append(args, id)
	_, err := r.db.Exec(fmt.Sprintf("UPDATE users SET %s WHERE id = $%d", sets, idx), args...)
	return err
}

func (r *Repository) CreateSection(id, title, description, tier string, ord int) error {
	_, err := r.db.Exec("INSERT INTO training_sections (id, title, description, tier, ord) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (id) DO UPDATE SET title = $2, description = $3, tier = $4, ord = $5", id, title, description, tier, ord)
	return err
}

func (r *Repository) CreateModule(id, title, originalTitle string, difficulty, minReadSeconds int, intelContent string) error {
	_, err := r.db.Exec("INSERT INTO cyber_modules (id, title, original_title, difficulty, min_read_seconds, intel_content) VALUES ($1, $2, $3, $4, $5, $6::jsonb) ON CONFLICT (id) DO UPDATE SET title = $2, original_title = $3, difficulty = $4, min_read_seconds = $5, intel_content = $6::jsonb", id, title, originalTitle, difficulty, minReadSeconds, intelContent)
	return err
}
