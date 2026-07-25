package runtime

import (
	"context"
	"time"

	"github.com/jmoiron/sqlx"
)

type RuntimeSession struct {
	ID                 string     `db:"id" json:"id"`
	UserID             string     `db:"user_id" json:"user_id"`
	EnrollmentID       *string    `db:"enrollment_id" json:"enrollment_id,omitempty"`
	LearningGoalID     *string    `db:"learning_goal_id" json:"learning_goal_id,omitempty"`
	PackID             *string    `db:"pack_id" json:"pack_id,omitempty"`
	PackVersion        *string    `db:"pack_version" json:"pack_version,omitempty"`
	CurrentNodeID      *string    `db:"current_node_id" json:"current_node_id,omitempty"`
	Status             string     `db:"status" json:"status"` // NOT_STARTED, RUNNING, PAUSED, FAILED, COMPLETED
	ProgressPercentage int        `db:"progress_percentage" json:"progress_percentage"`
	StartedAt          time.Time  `db:"started_at" json:"started_at"`
	LastActivityAt     time.Time  `db:"last_activity_at" json:"last_activity_at"`
	CompletedAt        *time.Time `db:"completed_at" json:"completed_at,omitempty"`
	Metadata           *string    `db:"metadata" json:"metadata,omitempty"`
}

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
		WHERE user_id = $1 AND status IN ('NOT_STARTED', 'RUNNING', 'PAUSED')
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
			completed_at = :completed_at,
			metadata = :metadata
		WHERE id = :id
	`
	_, err := r.db.NamedExecContext(ctx, query, session)
	return err
}
