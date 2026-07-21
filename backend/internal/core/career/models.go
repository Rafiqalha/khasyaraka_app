package career

import (
	"encoding/json"
	"time"
)

type CareerCandidate struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	TriggerType        string          `db:"trigger_type" json:"trigger_type"` // COMPETENCY_UPDATE, NEW_TARGET_ROLE
	TriggerRefID       *string         `db:"trigger_ref_id" json:"trigger_ref_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	Payload            json.RawMessage `db:"payload" json:"payload"`
	CreatedAt          time.Time       `db:"created_at" json:"created_at"`
}

type CareerEvent struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	CandidateID        *string         `db:"candidate_id" json:"candidate_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	ActionType         string          `db:"action_type" json:"action_type"` // GAP_DECREASED, GAP_INCREASED, ROLE_ACHIEVED, TARGET_SET
	TargetRoleID       string          `db:"target_role_id" json:"target_role_id"`
	Payload            json.RawMessage `db:"payload" json:"payload"`
	CreatedAt          time.Time       `db:"created_at" json:"created_at"`
}

type CareerProjection struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	TargetRoleID       string          `db:"target_role_id" json:"target_role_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	ReadinessScore     float64         `db:"readiness_score" json:"readiness_score"` // 0-100%
	GapAnalysisJSON    json.RawMessage `db:"gap_analysis_json" json:"gap_analysis_json"`
	Status             string          `db:"status" json:"status"`
	ProjectedAt        time.Time       `db:"projected_at" json:"projected_at"`
}
