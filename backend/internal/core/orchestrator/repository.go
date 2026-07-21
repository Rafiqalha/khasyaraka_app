package orchestrator

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	UpsertContext(ctx context.Context, c IntelligenceContext) error
	SaveDirective(ctx context.Context, d IntelligenceDirective) error
	GetLatestDirective(ctx context.Context, userID string) (*IntelligenceDirective, error)
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) UpsertContext(ctx context.Context, c IntelligenceContext) error {
	query := `
		INSERT INTO intelligence_contexts (id, user_id, epoch_id, memory_state_json, roadmap_state_json, career_state_json, portfolio_state_json, updated_at)
		VALUES (:id, :user_id, :epoch_id, :memory_state_json, :roadmap_state_json, :career_state_json, :portfolio_state_json, :updated_at)
		ON CONFLICT (user_id, epoch_id) DO UPDATE SET
			memory_state_json = COALESCE(EXCLUDED.memory_state_json, intelligence_contexts.memory_state_json),
			roadmap_state_json = COALESCE(EXCLUDED.roadmap_state_json, intelligence_contexts.roadmap_state_json),
			career_state_json = COALESCE(EXCLUDED.career_state_json, intelligence_contexts.career_state_json),
			portfolio_state_json = COALESCE(EXCLUDED.portfolio_state_json, intelligence_contexts.portfolio_state_json),
			updated_at = :updated_at
	`
	_, err := r.db.NamedExecContext(ctx, query, c)
	return err
}

func (r *repository) SaveDirective(ctx context.Context, d IntelligenceDirective) error {
	query := `
		INSERT INTO intelligence_directives (id, user_id, context_id, epoch_id, action_type, priority_score, directive_payload, created_at)
		VALUES (:id, :user_id, :context_id, :epoch_id, :action_type, :priority_score, :directive_payload, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, d)
	return err
}

func (r *repository) GetLatestDirective(ctx context.Context, userID string) (*IntelligenceDirective, error) {
	query := `
		SELECT * FROM intelligence_directives
		WHERE user_id = $1
		ORDER BY created_at DESC LIMIT 1
	`
	var d IntelligenceDirective
	if err := r.db.GetContext(ctx, &d, query, userID); err != nil {
		return nil, err
	}
	return &d, nil
}
