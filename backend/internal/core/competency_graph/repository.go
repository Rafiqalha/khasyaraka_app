package competency_graph

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	SaveContribution(ctx context.Context, c CompetencyContribution) error
	GetContributions(ctx context.Context, userID, skillNodeID string) ([]CompetencyContribution, error)

	SaveProjection(ctx context.Context, p CompetencyProjection) error
	GetLatestProjection(ctx context.Context, userID, skillNodeID string) (*CompetencyProjection, error)

	SaveSnapshot(ctx context.Context, s CapabilitySnapshot) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) SaveContribution(ctx context.Context, c CompetencyContribution) error {
	query := `
		INSERT INTO competency_contributions (id, user_id, evidence_id, skill_node_id, knowledge_lineage_id, kind, magnitude, confidence, weight, created_at)
		VALUES (:id, :user_id, :evidence_id, :skill_node_id, :knowledge_lineage_id, :kind, :magnitude, :confidence, :weight, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, c)
	return err
}

func (r *repository) GetContributions(ctx context.Context, userID, skillNodeID string) ([]CompetencyContribution, error) {
	var contribs []CompetencyContribution
	err := r.db.SelectContext(ctx, &contribs, "SELECT * FROM competency_contributions WHERE user_id = $1 AND skill_node_id = $2 ORDER BY created_at ASC", userID, skillNodeID)
	return contribs, err
}

func (r *repository) SaveProjection(ctx context.Context, p CompetencyProjection) error {
	query := `
		INSERT INTO competency_projections (id, user_id, skill_node_id, score, status, governance_bundle_id, root_fingerprint, snapshot_id, confidence, trend, velocity, stability, forecast_30_days, forecast_90_days, metrics_json, explanation_json, projected_at, expires_at)
		VALUES (:id, :user_id, :skill_node_id, :score, :status, :governance_bundle_id, :root_fingerprint, :snapshot_id, :confidence, :trend, :velocity, :stability, :forecast_30_days, :forecast_90_days, :metrics_json, :explanation_json, :projected_at, :expires_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, p)
	return err
}

func (r *repository) GetLatestProjection(ctx context.Context, userID, skillNodeID string) (*CompetencyProjection, error) {
	var p CompetencyProjection
	err := r.db.GetContext(ctx, &p, "SELECT * FROM competency_projections WHERE user_id = $1 AND skill_node_id = $2 ORDER BY projected_at DESC LIMIT 1", userID, skillNodeID)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *repository) SaveSnapshot(ctx context.Context, s CapabilitySnapshot) error {
	query := `
		INSERT INTO capability_snapshots (id, user_id, manifest, created_at)
		VALUES (:id, :user_id, :manifest, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, s)
	return err
}
