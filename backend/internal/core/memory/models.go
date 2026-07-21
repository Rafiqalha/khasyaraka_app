package memory

import (
	"encoding/json"
	"time"
)

type MemoryCandidate struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	SessionID          *string         `db:"session_id" json:"session_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	CompetencyDeltaID  *string         `db:"competency_delta_id" json:"competency_delta_id"`
	Payload            json.RawMessage `db:"payload" json:"payload"`
	CreatedAt          time.Time       `db:"created_at" json:"created_at"`
}

type MemoryEvent struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	CandidateID        *string         `db:"candidate_id" json:"candidate_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	MemoryType         string          `db:"memory_type" json:"memory_type"`
	Strength           float64         `db:"strength" json:"strength"`
	Payload            json.RawMessage `db:"payload" json:"payload"`
	CreatedAt          time.Time       `db:"created_at" json:"created_at"`
}

type MemoryProjection struct {
	ID                  string          `db:"id" json:"id"`
	UserID              string          `db:"user_id" json:"user_id"`
	MemoryNodeID        string          `db:"memory_node_id" json:"memory_node_id"`
	KnowledgeLineageID  string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID             string          `db:"epoch_id" json:"epoch_id"`
	RetentionScore      float64         `db:"retention_score" json:"retention_score"`
	MemoryState         string          `db:"memory_state" json:"memory_state"` // WORKING, SHORT_TERM, LONG_TERM
	ForgettingCurveJSON json.RawMessage `db:"forgetting_curve_json" json:"forgetting_curve_json"`
	Status              string          `db:"status" json:"status"`
	ExpiresAt           *time.Time      `db:"expires_at" json:"expires_at"`
	ProjectedAt         time.Time       `db:"projected_at" json:"projected_at"`
}
