package credential

import (
	"time"

	"github.com/pradigi/backend/internal/core/competency"
)

// CredentialStatus defines the lifecycle of a credential.
type CredentialStatus string

const (
	StatusDraft    CredentialStatus = "draft"
	StatusEligible CredentialStatus = "eligible"
	StatusClaimed  CredentialStatus = "claimed"
	StatusIssued   CredentialStatus = "issued"
	StatusArchived CredentialStatus = "archived"
)

// CredentialManifest defines the strict rules for an academy to award a credential.
// This is read from `credential.yaml` in the Academy SDK.
type CredentialManifest struct {
	ID           string `yaml:"id" json:"id"`
	Version      int    `yaml:"version" json:"version"`
	Title        string `yaml:"title" json:"title"`
	Requirements struct {
		Competencies []string `yaml:"competencies" json:"competencies"`
		Mastery      struct {
			Mean       float64 `yaml:"mean" json:"mean"`
			Confidence float64 `yaml:"confidence" json:"confidence"`
		} `yaml:"mastery" json:"mastery"`
		Evidence struct {
			Missions    int `yaml:"missions" json:"missions"`
			Reflections int `yaml:"reflections" json:"reflections"`
		} `yaml:"evidence" json:"evidence"`
		Behavior struct {
			Plagiarism            bool    `yaml:"plagiarism" json:"plagiarism"`
			ExcessiveAIDependency bool    `yaml:"excessive_ai_dependency" json:"excessive_ai_dependency"`
			IntegrityScore        float64 `yaml:"integrity_score" json:"integrity_score"`
		} `yaml:"behavior" json:"behavior"`
	} `yaml:"requirements" json:"requirements"`
}

// AssessmentSnapshot freezes the entire state of the user's competency and behavior at the exact moment of claiming.
type AssessmentSnapshot struct {
	SnapshotID            string                                `json:"snapshot_id" db:"snapshot_id"`
	KnowledgeGraphVersion string                                `json:"knowledge_graph_version" db:"knowledge_graph_version"`
	CompetencyState       map[string]competency.CompetencyState `json:"competency_state"`
	BehaviorFingerprint   map[string]interface{}                `json:"behavior_fingerprint"`
	EvidenceIDs           []string                              `json:"evidence_ids"`
	Timestamp             time.Time                             `json:"timestamp" db:"timestamp"`
}

// Credential is the actual issued certificate. It is immutable and points to the AssessmentSnapshot.
type Credential struct {
	ID                   string              `json:"id" db:"id"`
	UserID               string              `json:"user_id" db:"user_id"`
	CredentialManifestID string              `json:"credential_manifest_id" db:"credential_manifest_id"`
	Status               CredentialStatus    `json:"status" db:"status"`
	AssessmentSnapshot   *AssessmentSnapshot `json:"assessment_snapshot,omitempty"`
	IssuedAt             *time.Time          `json:"issued_at,omitempty" db:"issued_at"`
	CreatedAt            time.Time           `json:"created_at" db:"created_at"`
}
