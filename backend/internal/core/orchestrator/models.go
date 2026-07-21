package orchestrator

import (
	"encoding/json"
	"time"
)

type IntelligenceContext struct {
	ID                 string          `db:"id" json:"id"`
	UserID             string          `db:"user_id" json:"user_id"`
	EpochID            string          `db:"epoch_id" json:"epoch_id"`
	MemoryStateJSON    json.RawMessage `db:"memory_state_json" json:"memory_state_json"`
	RoadmapStateJSON   json.RawMessage `db:"roadmap_state_json" json:"roadmap_state_json"`
	CareerStateJSON    json.RawMessage `db:"career_state_json" json:"career_state_json"`
	PortfolioStateJSON json.RawMessage `db:"portfolio_state_json" json:"portfolio_state_json"`
	UpdatedAt          time.Time       `db:"updated_at" json:"updated_at"`
}

type IntelligenceDirective struct {
	ID               string          `db:"id" json:"id"`
	UserID           string          `db:"user_id" json:"user_id"`
	ContextID        string          `db:"context_id" json:"context_id"`
	EpochID          string          `db:"epoch_id" json:"epoch_id"`
	ActionType       string          `db:"action_type" json:"action_type"` // URGENT_REVIEW, PORTFOLIO_BUILDING, RESUME_ROADMAP
	PriorityScore    float64         `db:"priority_score" json:"priority_score"`
	DirectivePayload json.RawMessage `db:"directive_payload" json:"directive_payload"`
	CreatedAt        time.Time       `db:"created_at" json:"created_at"`
}
