package mission

import "github.com/pradigi/backend/internal/workbench/engine"

// ===========================
// Mission Blueprint
// The output of the Mission Planner. It dictates the specs of the mission
// but does not contain the actual code or narrative (that's the Generator's job).
// ===========================

type DifficultyLevel string

const (
	DiffEasy   DifficultyLevel = "EASY"
	DiffMedium DifficultyLevel = "MEDIUM"
	DiffHard   DifficultyLevel = "HARD"
	DiffExpert DifficultyLevel = "EXPERT"
)

type MissionBlueprint struct {
	Domain               string              `json:"domain"` // e.g., "python"
	Difficulty           DifficultyLevel     `json:"difficulty"`
	NeedMentor           bool                `json:"need_mentor"`
	AIBudget             int                 `json:"ai_budget"`
	EstimatedTimeMinutes int                 `json:"estimated_time_minutes"`
	RequiredCapabilities []string            `json:"required_capabilities"`
	TargetCompetency     string              `json:"target_competency"`
	Constraints          []engine.Constraint `json:"constraints"`
}
