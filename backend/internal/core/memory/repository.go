package memory

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	SaveCandidate(ctx context.Context, c MemoryCandidate) error
	SaveEvent(ctx context.Context, e MemoryEvent) error
	SaveProjection(ctx context.Context, p MemoryProjection) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) SaveCandidate(ctx context.Context, c MemoryCandidate) error {
	query := `
		INSERT INTO memory_candidates (id, user_id, session_id, knowledge_lineage_id, epoch_id, competency_delta_id, payload, created_at)
		VALUES (:id, :user_id, :session_id, :knowledge_lineage_id, :epoch_id, :competency_delta_id, :payload, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, c)
	return err
}

func (r *repository) SaveEvent(ctx context.Context, e MemoryEvent) error {
	query := `
		INSERT INTO memory_events (id, user_id, candidate_id, knowledge_lineage_id, epoch_id, memory_type, strength, payload, created_at)
		VALUES (:id, :user_id, :candidate_id, :knowledge_lineage_id, :epoch_id, :memory_type, :strength, :payload, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, e)
	return err
}

func (r *repository) SaveProjection(ctx context.Context, p MemoryProjection) error {
	query := `
		INSERT INTO memory_projections (id, user_id, memory_node_id, knowledge_lineage_id, epoch_id, retention_score, memory_state, forgetting_curve_json, status, expires_at, projected_at)
		VALUES (:id, :user_id, :memory_node_id, :knowledge_lineage_id, :epoch_id, :retention_score, :memory_state, :forgetting_curve_json, :status, :expires_at, :projected_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, p)
	return err
}
