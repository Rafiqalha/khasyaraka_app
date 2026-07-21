package evidence

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	SaveEvidence(ctx context.Context, e Evidence) error
	GetEvidence(ctx context.Context, id string) (*Evidence, error)
	GetEvidencesByObservation(ctx context.Context, obsID string) ([]Evidence, error)
	
	SaveResolution(ctx context.Context, r EvidenceResolution, relatedEvidenceIDs []string) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) SaveEvidence(ctx context.Context, e Evidence) error {
	query := `
		INSERT INTO evidences (id, observation_id, skill_node_id, evidence_type, status, fingerprint, direction, strength, reason, validity_end_at, weight, created_at)
		VALUES (:id, :observation_id, :skill_node_id, :evidence_type, :status, :fingerprint, :direction, :strength, :reason, :validity_end_at, :weight, :created_at)
	`
	_, err := r.db.NamedExecContext(ctx, query, e)
	return err
}

func (r *repository) GetEvidence(ctx context.Context, id string) (*Evidence, error) {
	var e Evidence
	err := r.db.GetContext(ctx, &e, "SELECT * FROM evidences WHERE id = $1", id)
	if err != nil {
		return nil, err
	}
	return &e, nil
}

func (r *repository) GetEvidencesByObservation(ctx context.Context, obsID string) ([]Evidence, error) {
	var evs []Evidence
	err := r.db.SelectContext(ctx, &evs, "SELECT * FROM evidences WHERE observation_id = $1", obsID)
	return evs, err
}

func (r *repository) SaveResolution(ctx context.Context, res EvidenceResolution, relatedEvidenceIDs []string) error {
	tx, err := r.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	
	q1 := `INSERT INTO evidence_resolutions (id, resolution_type, winning_evidence_id, confidence, reason, created_at)
	       VALUES (:id, :resolution_type, :winning_evidence_id, :confidence, :reason, :created_at)`
	if _, err := tx.NamedExecContext(ctx, q1, res); err != nil {
		return err
	}
	
	q2 := `INSERT INTO evidence_resolution_items (resolution_id, evidence_id) VALUES ($1, $2)`
	for _, eid := range relatedEvidenceIDs {
		if _, err := tx.ExecContext(ctx, q2, res.ID, eid); err != nil {
			return err
		}
	}
	
	return tx.Commit()
}
