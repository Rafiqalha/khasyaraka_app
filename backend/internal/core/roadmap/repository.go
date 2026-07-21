package roadmap

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	SaveCandidate(ctx context.Context, c RoadmapCandidate) error
	SaveEvent(ctx context.Context, e RoadmapEvent) error
	SaveProjection(ctx context.Context, p RoadmapProjection) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) SaveCandidate(ctx context.Context, c RoadmapCandidate) error {
	query := `
		INSERT INTO roadmap_candidates (id, user_id, trigger_type, trigger_ref_id, knowledge_lineage_id, epoch_id, payload, created_at)
		VALUES (:id, :user_id, :trigger_type, :trigger_ref_id, :knowledge_lineage_id, :epoch_id, :payload, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, c)
	return err
}

func (r *repository) SaveEvent(ctx context.Context, e RoadmapEvent) error {
	query := `
		INSERT INTO roadmap_events (id, user_id, candidate_id, knowledge_lineage_id, epoch_id, action_type, node_id, payload, created_at)
		VALUES (:id, :user_id, :candidate_id, :knowledge_lineage_id, :epoch_id, :action_type, :node_id, :payload, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, e)
	return err
}

func (r *repository) SaveProjection(ctx context.Context, p RoadmapProjection) error {
	query := `
		INSERT INTO roadmap_projections (id, user_id, knowledge_lineage_id, epoch_id, active_nodes_json, status, projected_at)
		VALUES (:id, :user_id, :knowledge_lineage_id, :epoch_id, :active_nodes_json, :status, :projected_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, p)
	return err
}
