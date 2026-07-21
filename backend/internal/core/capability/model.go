package capability

import "time"

type Domain struct {
	ID          string `db:"id"`
	Slug        string `db:"slug"`
	Title       string `db:"title"`
	Description string `db:"description"`
}

type Skill struct {
	ID          string `db:"id"`
	DomainID    string `db:"domain_id"`
	Slug        string `db:"slug"`
	Title       string `db:"title"`
	Description string `db:"description"`
}

type LearnerCapability struct {
	ID               string    `db:"id"`
	UserID           string    `db:"user_id"`
	SkillID          string    `db:"skill_id"`
	ProficiencyScore int       `db:"proficiency_score"`
	EvidenceScore    float64   `db:"evidence_score"`
	LastAssessedAt   time.Time `db:"last_assessed_at"`
	CreatedAt        time.Time `db:"created_at"`
}

type CapabilityLog struct {
	ID           string    `db:"id"`
	CapabilityID string    `db:"capability_id"`
	SourceType   string    `db:"source_type"`
	SourceID     string    `db:"source_id"`
	DeltaScore   int       `db:"delta_score"`
	Summary      string    `db:"summary"`
	CreatedAt    time.Time `db:"created_at"`
}
