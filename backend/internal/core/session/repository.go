package session

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	CreateSession(ctx context.Context, s LearningSession) error
	UpdateSession(ctx context.Context, s LearningSession) error
	GetActiveSession(ctx context.Context, userID string) (*LearningSession, error)
	AddActivityToSession(ctx context.Context, sa SessionActivity) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) CreateSession(ctx context.Context, s LearningSession) error {
	query := `
		INSERT INTO learning_sessions (id, user_id, tenant_id, status, started_at, ended_at, duration_sec)
		VALUES (:id, :user_id, :tenant_id, :status, :started_at, :ended_at, :duration_sec)
	`
	_, err := r.db.NamedExecContext(ctx, query, s)
	return err
}

func (r *repository) UpdateSession(ctx context.Context, s LearningSession) error {
	query := `
		UPDATE learning_sessions 
		SET status = :status, ended_at = :ended_at, duration_sec = :duration_sec
		WHERE id = :id
	`
	_, err := r.db.NamedExecContext(ctx, query, s)
	return err
}

func (r *repository) GetActiveSession(ctx context.Context, userID string) (*LearningSession, error) {
	var s LearningSession
	query := `
		SELECT * FROM learning_sessions 
		WHERE user_id = $1 AND status = 'ACTIVE' 
		ORDER BY started_at DESC LIMIT 1
	`
	err := r.db.GetContext(ctx, &s, query, userID)
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (r *repository) AddActivityToSession(ctx context.Context, sa SessionActivity) error {
	query := `
		INSERT INTO session_activities (session_id, activity_id, sequence)
		VALUES (:session_id, :activity_id, :sequence)
	`
	_, err := r.db.NamedExecContext(ctx, query, sa)
	return err
}
