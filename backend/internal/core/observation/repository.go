package observation

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	SaveCandidate(ctx context.Context, c ObservationCandidate) error
	GetCandidate(ctx context.Context, id string) (*ObservationCandidate, error)
	
	SaveObservation(ctx context.Context, o Observation) error
	GetObservation(ctx context.Context, id string) (*Observation, error)
	
	SaveValidationReport(ctx context.Context, r ValidationReport) error
	SaveEvidence(ctx context.Context, e Evidence) error
	
	GetPromptBundle(ctx context.Context, name, version string) (*PromptBundle, error)
	SavePromptBundle(ctx context.Context, p PromptBundle) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) SaveCandidate(ctx context.Context, c ObservationCandidate) error {
	query := `
		INSERT INTO observation_candidates (id, session_id, fingerprint, created_at)
		VALUES (:id, :session_id, :fingerprint, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, c)
	return err
}

func (r *repository) GetCandidate(ctx context.Context, id string) (*ObservationCandidate, error) {
	var c ObservationCandidate
	err := r.db.GetContext(ctx, &c, "SELECT * FROM observation_candidates WHERE id = $1", id)
	if err != nil {
		return nil, err
	}
	return &c, nil
}

func (r *repository) SaveObservation(ctx context.Context, o Observation) error {
	query := `
		INSERT INTO observations (id, candidate_id, parent_observation_id, prompt_bundle_id, model_id, inference_profile_id, input_fingerprint, execution_fingerprint, status, observation_type, confidence, observation_quality, summary, ai_latency_ms, ai_cost, ai_usage, ai_request_id, provenance, created_at)
		VALUES (:id, :candidate_id, :parent_observation_id, :prompt_bundle_id, :model_id, :inference_profile_id, :input_fingerprint, :execution_fingerprint, :status, :observation_type, :confidence, :observation_quality, :summary, :ai_latency_ms, :ai_cost, :ai_usage, :ai_request_id, :provenance, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, o)
	return err
}

func (r *repository) GetObservation(ctx context.Context, id string) (*Observation, error) {
	var o Observation
	err := r.db.GetContext(ctx, &o, "SELECT * FROM observations WHERE id = $1", id)
	if err != nil {
		return nil, err
	}
	return &o, nil
}

func (r *repository) SaveValidationReport(ctx context.Context, vr ValidationReport) error {
	// Dummy for brevity - would convert arrays to JSONB
	return nil
}

func (r *repository) SaveEvidence(ctx context.Context, e Evidence) error {
	query := `
		INSERT INTO evidences (id, observation_id, skill_id, direction, strength, reason, created_at)
		VALUES (:id, :observation_id, :skill_id, :direction, :strength, :reason, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, e)
	return err
}

func (r *repository) GetPromptBundle(ctx context.Context, name, version string) (*PromptBundle, error) {
	var p PromptBundle
	err := r.db.GetContext(ctx, &p, "SELECT * FROM prompt_bundles WHERE name = $1 AND version = $2", name, version)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *repository) SavePromptBundle(ctx context.Context, p PromptBundle) error {
	query := `
		INSERT INTO prompt_bundles (id, name, version, hash, created_at)
		VALUES (:id, :name, :version, :hash, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, p)
	return err
}
