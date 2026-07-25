package planner

import (
	"context"

	"github.com/pradigi/backend/internal/core/pack"
)

type AdaptivePlanner struct{}

func NewAdaptivePlanner() *AdaptivePlanner {
	return &AdaptivePlanner{}
}

func (p *AdaptivePlanner) Plan(ctx context.Context, sessionID string, pkg *pack.Pack, snapshot CapabilitySnapshot) (*MissionPlan, error) {
	// 1. Identify which capability needs focus.
	// (Simple logic: just pick the first capability for now)
	var targetCap pack.Capability
	if len(pkg.Capabilities) > 0 {
		targetCap = pkg.Capabilities[0]
	}

	// 2. Define Pedagogy
	// In a real scenario, this is derived from user profile (e.g. they prefer Socratic)
	pedagogy := PedagogyConfig{
		Strategy:              "discovery_learning",
		HintStrategy:          "incremental",
		FeedbackType:          "conceptual",
		DifficultyProgression: "adaptive",
	}

	// 3. Construct Mission Plan
	plan := &MissionPlan{
		SessionID:        sessionID,
		TargetCapability: targetCap,
		Difficulty:       1,
		Workspace:        pkg.Workspace,
		Pedagogy:         pedagogy,
		EstimatedTimeSec: 600,
	}

	return plan, nil
}
