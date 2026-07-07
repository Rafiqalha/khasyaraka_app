package sku

import (
	"database/sql"
	"encoding/json"
	"fmt"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func scanJSON(dest interface{}, src interface{}) error {
	switch s := src.(type) {
	case []byte:
		return json.Unmarshal(s, dest)
	case string:
		return json.Unmarshal([]byte(s), dest)
	default:
		return fmt.Errorf("unexpected type %T for JSON", src)
	}
}

func (r *Repository) GetPoints() ([]SKUPoint, error) {
	var points []SKUPoint
	rows, err := r.db.Queryx("SELECT id, level, number, title, description, category, quiz_content FROM sku_points ORDER BY level, number")
	if err != nil {
		return nil, fmt.Errorf("get sku points: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var p SKUPoint
		var qcRaw interface{}
		err := rows.Scan(&p.ID, &p.Level, &p.Number, &p.Title, &p.Description, &p.Category, &qcRaw)
		if err != nil {
			return nil, fmt.Errorf("scan sku point: %w", err)
		}
		if err := scanJSON(&p.QuizContent, qcRaw); err != nil {
			return nil, err
		}
		points = append(points, p)
	}
	return points, nil
}

func (r *Repository) GetPointsByIDs(ids []string) ([]SKUPoint, error) {
	if len(ids) == 0 {
		return nil, nil
	}
	q, args, err := sqlx.In("SELECT id, level, number, title, description, category, quiz_content FROM sku_points WHERE id IN (?)", ids)
	if err != nil {
		return nil, err
	}
	q = r.db.Rebind(q)
	rows, err := r.db.Queryx(q, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var points []SKUPoint
	for rows.Next() {
		var p SKUPoint
		var qcRaw interface{}
		if err := rows.Scan(&p.ID, &p.Level, &p.Number, &p.Title, &p.Description, &p.Category, &qcRaw); err != nil {
			return nil, err
		}
		if err := scanJSON(&p.QuizContent, qcRaw); err != nil {
			return nil, err
		}
		points = append(points, p)
	}
	return points, nil
}

func (r *Repository) GetPointByID(id string) (*SKUPoint, error) {
	var p SKUPoint
	var qcRaw interface{}
	err := r.db.QueryRowx("SELECT id, level, number, title, description, category, quiz_content FROM sku_points WHERE id = $1", id).Scan(
		&p.ID, &p.Level, &p.Number, &p.Title, &p.Description, &p.Category, &qcRaw,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get sku point: %w", err)
	}
	if err := scanJSON(&p.QuizContent, qcRaw); err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *Repository) GetProgress(userID int64) (map[string]SKUProgress, error) {
	var progress []SKUProgress
	err := r.db.Select(&progress, "SELECT user_id, sku_point_id, is_completed, score FROM sku_progress WHERE user_id = $1", userID)
	if err != nil {
		return nil, fmt.Errorf("get progress: %w", err)
	}
	m := make(map[string]SKUProgress)
	for _, p := range progress {
		m[p.SKUPointID] = p
	}
	return m, nil
}

func (r *Repository) MarkCompleted(userID int64, pointID string, score int) error {
	_, err := r.db.Exec(`
		INSERT INTO sku_progress (user_id, sku_point_id, is_completed, score)
		VALUES ($1, $2, TRUE, $3)
		ON CONFLICT (user_id, sku_point_id) DO UPDATE SET is_completed = TRUE, score = GREATEST(sku_progress.score, $3)
	`, userID, pointID, score)
	return err
}

func (r *Repository) GetFirstActiveDate(userID int64) (sql.NullTime, error) {
	var firstActive sql.NullTime
	err := r.db.QueryRow("SELECT first_active_date FROM users WHERE id = $1", userID).Scan(&firstActive)
	return firstActive, err
}

func (r *Repository) SetFirstActiveDateToToday(userID int64) error {
	_, err := r.db.Exec("UPDATE users SET first_active_date = CURRENT_DATE WHERE id = $1", userID)
	return err
}
