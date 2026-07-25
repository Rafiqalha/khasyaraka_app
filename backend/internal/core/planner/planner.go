package planner

import (
	"context"

	"github.com/pradigi/backend/internal/core/pack"
)

// PedagogyConfig defines the learning strategy applied to the mission.
type PedagogyConfig struct {
	Strategy              string `json:"strategy"` // e.g. "discovery_learning", "socratic"
	HintStrategy          string `json:"hint_strategy"`
	FeedbackType          string `json:"feedback_type"`
	DifficultyProgression string `json:"difficulty_progression"`
}

// CapabilitySnapshot represents the current state of a user's skills.
type CapabilitySnapshot struct {
	UserID         string
	Scores         map[string]float64 // e.g., {"cap_array_memory": 0.8}
	RecentEvidence []string
}

// MissionPlan is the exact specification of WHAT the user should learn and HOW.
// It is fully isolated from AI prompts.
type MissionPlan struct {
	SessionID        string
	TargetCapability pack.Capability
	Difficulty       int
	Workspace        pack.WorkspaceConfig
	Pedagogy         PedagogyConfig
	EstimatedTimeSec int
}

// Planner acts as the strategic intelligence that decides what mission a user should do next.
type Planner interface {
	Plan(ctx context.Context, sessionID string, p *pack.Pack, snapshot CapabilitySnapshot) (*MissionPlan, error)
}
