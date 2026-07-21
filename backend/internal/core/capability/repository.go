package capability

import (
	"github.com/jmoiron/sqlx"
)

type Repository interface {
	GetUserCapabilities(userID string) ([]CapabilityResponse, error)
	UpsertCapability(cap *LearnerCapability) error
	LogEvaluation(log *CapabilityLog) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) GetUserCapabilities(userID string) ([]CapabilityResponse, error) {
	query := `
		SELECT 
			c.skill_id,
			d.slug as domain_slug,
			s.slug as skill_slug,
			s.title as skill_title,
			c.proficiency_score,
			(c.proficiency_score / 10) as normalized_score,
			c.evidence_score
		FROM learner_capabilities c
		JOIN skills s ON c.skill_id = s.id
		JOIN domains d ON s.domain_id = d.id
		WHERE c.user_id = $1
	`
	var caps []CapabilityResponse
	err := r.db.Select(&caps, query, userID)
	return caps, err
}

func (r *repository) UpsertCapability(cap *LearnerCapability) error {
	query := `
		INSERT INTO learner_capabilities (
			user_id, skill_id, proficiency_score, evidence_score, last_assessed_at, updated_at
		) VALUES (
			:user_id, :skill_id, :proficiency_score, :evidence_score, NOW(), NOW()
		)
		ON CONFLICT (user_id, skill_id) DO UPDATE SET
			proficiency_score = EXCLUDED.proficiency_score,
			evidence_score = EXCLUDED.evidence_score,
			last_assessed_at = NOW(),
			updated_at = NOW()
		RETURNING id
	`
	
	// NamedQuery is used to return the ID if needed for logs
	rows, err := r.db.NamedQuery(query, cap)
	if err != nil {
		return err
	}
	defer rows.Close()
	
	if rows.Next() {
		err = rows.Scan(&cap.ID)
	}
	
	return err
}

func (r *repository) LogEvaluation(log *CapabilityLog) error {
	query := `
		INSERT INTO capability_logs (
			capability_id, source_type, source_id, delta_score, summary
		) VALUES (
			:capability_id, :source_type, :source_id, :delta_score, :summary
		)
	`
	_, err := r.db.NamedExec(query, log)
	return err
}
