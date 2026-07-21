package mission

import (
	"github.com/pradigi/backend/internal/core/adaptive_learning/planner"
	"github.com/pradigi/backend/internal/workbench/engine"
)

// ===========================
// Mission Planner (The Strategist)
// Translates Learning Intent into a concrete Mission Blueprint.
// Understands Workbench concepts (Capabilities, AI Budget).
// ===========================

type MissionPlanner struct{}

func NewMissionPlanner() *MissionPlanner {
	return &MissionPlanner{}
}

func (p *MissionPlanner) Plan(intent *planner.LearningIntent, strategy planner.LearningStrategy, domain string, constraints []engine.Constraint) *MissionBlueprint {
	bp := &MissionBlueprint{
		Domain:               domain, // e.g., "python"
		RequiredCapabilities: []string{"code_editor", "terminal"},
		Constraints:          constraints,
		TargetCompetency:     intent.TargetCompetencies[0], // Simplify for slice
	}

	switch strategy {
	case planner.StrategyChallenge:
		bp.Difficulty = DiffHard
		bp.NeedMentor = false
		bp.AIBudget = 1 // Strict
		bp.EstimatedTimeMinutes = 15
	case planner.StrategyConfidenceBuilding:
		bp.Difficulty = DiffEasy
		bp.NeedMentor = true
		bp.AIBudget = 5 // Liberal
		bp.EstimatedTimeMinutes = 30
		bp.RequiredCapabilities = append(bp.RequiredCapabilities, "mentor")
	case planner.StrategyScaffolding:
		bp.Difficulty = DiffMedium
		bp.NeedMentor = true
		bp.AIBudget = 3
		bp.EstimatedTimeMinutes = 20
		bp.RequiredCapabilities = append(bp.RequiredCapabilities, "mentor")
	default:
		bp.Difficulty = DiffMedium
		bp.NeedMentor = true
		bp.AIBudget = 3
		bp.EstimatedTimeMinutes = 20
	}

	return bp
}
