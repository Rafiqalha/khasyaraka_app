package career

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	SaveCandidate(ctx context.Context, c CareerCandidate) error
	SaveEvent(ctx context.Context, e CareerEvent) error
	SaveProjection(ctx context.Context, p CareerProjection) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) SaveCandidate(ctx context.Context, c CareerCandidate) error {
	query := `
		INSERT INTO career_candidates (id, user_id, trigger_type, trigger_ref_id, knowledge_lineage_id, epoch_id, payload, created_at)
		VALUES (:id, :user_id, :trigger_type, :trigger_ref_id, :knowledge_lineage_id, :epoch_id, :payload, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, c)
	return err
}

func (r *repository) SaveEvent(ctx context.Context, e CareerEvent) error {
	query := `
		INSERT INTO career_events (id, user_id, candidate_id, knowledge_lineage_id, epoch_id, action_type, target_role_id, payload, created_at)
		VALUES (:id, :user_id, :candidate_id, :knowledge_lineage_id, :epoch_id, :action_type, :target_role_id, :payload, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, e)
	return err
}

func (r *repository) SaveProjection(ctx context.Context, p CareerProjection) error {
	query := `
		INSERT INTO career_projections (id, user_id, target_role_id, knowledge_lineage_id, epoch_id, readiness_score, gap_analysis_json, status, projected_at)
		VALUES (:id, :user_id, :target_role_id, :knowledge_lineage_id, :epoch_id, :readiness_score, :gap_analysis_json, :status, :projected_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, p)
	return err
}
