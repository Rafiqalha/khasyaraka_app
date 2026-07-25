package evidence

import "time"

// EvidencePackage represents the comprehensive, reproducible snapshot
// generated when a user completes a node (especially MISSION).
type EvidencePackage struct {
	ID        string `json:"id"`
	JourneyID string `json:"journey_id"`
	NodeID    string `json:"node_id"`

	MissionFingerprint   string `json:"mission_fingerprint"`
	BehaviorFingerprint  string `json:"behavior_fingerprint"`
	ExecutionFingerprint string `json:"execution_fingerprint"`

	NotebookVersion      string `json:"notebook_version"`
	FixtureVersion       string `json:"fixture_version"`
	WorkspaceVersion     string `json:"workspace_version"`
	AdaptivePlanVersion  string `json:"adaptive_plan_version"`
	DecisionGraphVersion string `json:"decision_graph_version"`

	LearningObjectivesAchieved []string `json:"learning_objectives_achieved"`

	CreatedAt time.Time `json:"created_at"`
}

const (
	StatusGenerated = "GENERATED"
	StatusResolved  = "RESOLVED"
	StatusRejected  = "REJECTED"
)

type Evidence struct {
	ID            string     `json:"id" db:"id"`
	ObservationID string     `json:"observation_id" db:"observation_id"`
	SkillNodeID   *string    `json:"skill_node_id" db:"skill_node_id"`
	EvidenceType  string     `json:"evidence_type" db:"evidence_type"`
	Status        string     `json:"status" db:"status"`
	Fingerprint   string     `json:"fingerprint" db:"fingerprint"`
	Direction     string     `json:"direction" db:"direction"`
	Strength      float64    `json:"strength" db:"strength"`
	Reason        string     `json:"reason" db:"reason"`
	ValidityEndAt *time.Time `json:"validity_end_at" db:"validity_end_at"`
	Weight        float64    `json:"weight" db:"weight"`
	CreatedAt     time.Time  `json:"created_at" db:"created_at"`
}

type CompetencyDelta struct {
	SkillID     string   `json:"skillId"`
	Before      float64  `json:"before"`
	After       float64  `json:"after"`
	Confidence  float64  `json:"confidence"`
	Reason      string   `json:"reason"`
	EvidenceIDs []string `json:"evidenceIds"`
}

type EvidenceResolution struct {
	ID                string    `json:"id" db:"id"`
	ResolutionType    string    `json:"resolution_type" db:"resolution_type"`
	WinningEvidenceID string    `json:"winning_evidence_id" db:"winning_evidence_id"`
	Confidence        float64   `json:"confidence" db:"confidence"`
	Reason            string    `json:"reason" db:"reason"`
	CreatedAt         time.Time `json:"created_at" db:"created_at"`
}
