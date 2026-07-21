package portfolio

import (
	"encoding/json"
	"time"
)

type PortfolioCandidate struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	TriggerType        string          `db:"trigger_type" json:"trigger_type"` // EVIDENCE_RESOLVED
	TriggerRefID       *string         `db:"trigger_ref_id" json:"trigger_ref_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	Payload            json.RawMessage `db:"payload" json:"payload"`
	CreatedAt          time.Time       `db:"created_at" json:"created_at"`
}

type PortfolioEvent struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	CandidateID        *string         `db:"candidate_id" json:"candidate_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	ActionType         string          `db:"action_type" json:"action_type"` // ASSET_PUBLISHED, ASSET_WITHDRAWN, HIGHLIGHT_SET
	AssetID            string          `db:"asset_id" json:"asset_id"`
	Payload            json.RawMessage `db:"payload" json:"payload"`
	CreatedAt          time.Time       `db:"created_at" json:"created_at"`
}

type PortfolioProjection struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	PublicShowcaseJSON json.RawMessage `db:"public_showcase_json" json:"public_showcase_json"`
	Status             string          `db:"status" json:"status"`
	ProjectedAt        time.Time       `db:"projected_at" json:"projected_at"`
}
