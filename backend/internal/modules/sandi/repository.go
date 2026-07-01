package sandi

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

func (r *Repository) GetTypes() ([]SandiType, error) {
	var types []SandiType
	err := r.db.Select(&types, "SELECT id, codename, name, description, difficulty, category FROM sandi_types ORDER BY difficulty, name")
	if err != nil {
		return nil, fmt.Errorf("get sandi types: %w", err)
	}
	return types, nil
}

func (r *Repository) GetTypeByID(id int64) (*SandiType, error) {
	var st SandiType
	err := r.db.Get(&st, "SELECT id, codename, name, description, difficulty, category FROM sandi_types WHERE id = $1", id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get sandi type: %w", err)
	}
	return &st, nil
}

func (r *Repository) GetQuestionsBySandiID(sandiID int64) ([]SandiQuestion, error) {
	var questions []SandiQuestion
	err := r.db.Select(&questions, "SELECT id, sandi_id, question_text, encrypted_text, correct_answer, hint, difficulty, xp_reward FROM sandi_questions WHERE sandi_id = $1 ORDER BY difficulty, id", sandiID)
	if err != nil {
		return nil, fmt.Errorf("get sandi questions: %w", err)
	}
	return questions, nil
}

func (r *Repository) GetQuestionByID(id int64) (*SandiQuestion, error) {
	var q SandiQuestion
	err := r.db.Get(&q, "SELECT id, sandi_id, question_text, encrypted_text, correct_answer, hint, difficulty, xp_reward FROM sandi_questions WHERE id = $1", id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get question: %w", err)
	}
	return &q, nil
}

func (r *Repository) LogEncryption(userID int64, sandiID int64, inputHash string, mode string) error {
	_, err := r.db.Exec("INSERT INTO encryption_logs (user_id, sandi_id, input_hash, operation_mode) VALUES ($1, $2, $3, $4)", userID, sandiID, inputHash, mode)
	return err
}

func (r *Repository) UpdateUserXP(userID int64, xp int) error {
	_, err := r.db.Exec("UPDATE users SET total_xp = total_xp + $1, updated_at = NOW() WHERE id = $2", xp, userID)
	return err
}
