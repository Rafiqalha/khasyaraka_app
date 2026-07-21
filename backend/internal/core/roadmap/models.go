package roadmap

import (
	"encoding/json"
	"time"
)

type RoadmapCandidate struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	TriggerType        string          `db:"trigger_type" json:"trigger_type"` // MEMORY_DECAY, COMPETENCY_ACHIEVED, USER_INTENT
	TriggerRefID       *string         `db:"trigger_ref_id" json:"trigger_ref_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	Payload            json.RawMessage `db:"payload" json:"payload"`
	CreatedAt          time.Time       `db:"created_at" json:"created_at"`
}

type RoadmapEvent struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	CandidateID        *string         `db:"candidate_id" json:"candidate_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	ActionType         string          `db:"action_type" json:"action_type"` // ADD_NODE, REMOVE_NODE, REPRIORITIZE
	NodeID             string          `db:"node_id" json:"node_id"`
	Payload            json.RawMessage `db:"payload" json:"payload"`
	CreatedAt          time.Time       `db:"created_at" json:"created_at"`
}

type RoadmapProjection struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	KnowledgeLineageID string          `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	ActiveNodesJSON    json.RawMessage `db:"active_nodes_json" json:"active_nodes_json"` // Order sequence of nodes
	Status             string          `db:"status" json:"status"`
	ProjectedAt        time.Time       `db:"projected_at" json:"projected_at"`
}
