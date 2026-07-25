package evidence_validator

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

// CreateSubmission inserts a new submission into the DB, and creates the first event.
// Returns the SubmissionID.
func (r *Repository) CreateSubmission(ctx context.Context, sub *Submission) error {
	tx, err := r.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	query := `
		INSERT INTO submissions (
			id, correlation_id, user_id, learning_session_id, mission_id, node_id,
			attempt_number, priority, status, idempotency_key, 
			evaluator_version, policy_version, curriculum_version, mission_version
		) VALUES (
			:id, :correlation_id, :user_id, :learning_session_id, :mission_id, :node_id,
			:attempt_number, :priority, :status, :idempotency_key,
			:evaluator_version, :policy_version, :curriculum_version, :mission_version
		)
	`

	if sub.ID == "" {
		sub.ID = uuid.NewString()
	}

	_, err = tx.NamedExecContext(ctx, query, sub)
	if err != nil {
		return fmt.Errorf("insert submission: %w", err)
	}

	// Create initial event
	event := SubmissionEvent{
		ID:             uuid.NewString(),
		SubmissionID:   sub.ID,
		EventID:        "SubmissionCreated",
		SequenceNumber: 1,
		NewStatus:      StatusQueued,
		CreatedAt:      time.Now(),
	}

	eventQuery := `
		INSERT INTO submission_events (
			id, submission_id, event_id, sequence_number, new_status, created_at
		) VALUES (
			:id, :submission_id, :event_id, :sequence_number, :new_status, :created_at
		)
	`
	_, err = tx.NamedExecContext(ctx, eventQuery, event)
	if err != nil {
		return fmt.Errorf("insert submission_event: %w", err)
	}

	return tx.Commit()
}

func (r *Repository) GetSubmissionByID(ctx context.Context, id string) (*Submission, error) {
	var sub Submission
	err := r.db.GetContext(ctx, &sub, "SELECT * FROM submissions WHERE id = $1", id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &sub, nil
}

func (r *Repository) UpdateStatusWithEvent(ctx context.Context, subID string, oldStatus, newStatus SubmissionStatus, eventID string, payload interface{}, durationMs *int, actor *string) error {
	tx, err := r.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Update main table
	_, err = tx.ExecContext(ctx, "UPDATE submissions SET status = $1 WHERE id = $2", newStatus, subID)
	if err != nil {
		return err
	}

	// Get next sequence number
	var seq int
	err = tx.GetContext(ctx, &seq, "SELECT COALESCE(MAX(sequence_number), 0) + 1 FROM submission_events WHERE submission_id = $1", subID)
	if err != nil {
		return err
	}

	var payloadBytes []byte
	if payload != nil {
		payloadBytes, _ = json.Marshal(payload)
	}

	oldStatusStr := string(oldStatus)

	event := SubmissionEvent{
		ID:             uuid.NewString(),
		SubmissionID:   subID,
		EventID:        eventID,
		SequenceNumber: seq,
		PreviousStatus: &oldStatusStr,
		NewStatus:      newStatus,
		DurationMs:     durationMs,
		Actor:          actor,
		Payload:        payloadBytes,
		CreatedAt:      time.Now(),
	}

	eventQuery := `
		INSERT INTO submission_events (
			id, submission_id, event_id, sequence_number, previous_status, new_status, duration_ms, actor, payload, created_at
		) VALUES (
			:id, :submission_id, :event_id, :sequence_number, :previous_status, :new_status, :duration_ms, :actor, :payload, :created_at
		)
	`
	_, err = tx.NamedExecContext(ctx, eventQuery, event)
	if err != nil {
		return err
	}

	return tx.Commit()
}

func (r *Repository) GetIdempotentSubmission(ctx context.Context, key string) (*Submission, error) {
	var sub Submission
	err := r.db.GetContext(ctx, &sub, "SELECT * FROM submissions WHERE idempotency_key = $1", key)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &sub, nil
}
