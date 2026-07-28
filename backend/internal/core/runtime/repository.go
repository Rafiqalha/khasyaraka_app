package runtime

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) GetActiveSession(ctx context.Context, userID string) (*RuntimeSession, error) {
	var session RuntimeSession
	query := `
		SELECT * FROM runtime_sessions
		WHERE user_id = $1
		ORDER BY last_activity_at DESC
		LIMIT 1
	`
	err := r.db.GetContext(ctx, &session, query, userID)
	if err != nil {
		return nil, err
	}
	return &session, nil
}

func (r *Repository) CreateSession(ctx context.Context, session *RuntimeSession) error {
	query := `
		INSERT INTO runtime_sessions (
			user_id, learning_goal_id, pack_id, pack_version, current_node_id, status
		) VALUES (
			:user_id, :learning_goal_id, :pack_id, :pack_version, :current_node_id, :status
		) RETURNING id, started_at, last_activity_at, progress_percentage
	`
	rows, err := r.db.NamedQueryContext(ctx, query, session)
	if err != nil {
		return err
	}
	defer rows.Close()

	if rows.Next() {
		return rows.StructScan(session)
	}
	return nil
}

func (r *Repository) UpdateSession(ctx context.Context, session *RuntimeSession) error {
	query := `
		UPDATE runtime_sessions SET
			current_node_id = :current_node_id,
			status = :status,
			progress_percentage = :progress_percentage,
			last_activity_at = CURRENT_TIMESTAMP,
			completed_at = :completed_at
		WHERE id = :id
	`
	_, err := r.db.NamedExecContext(ctx, query, session)
	return err
}
