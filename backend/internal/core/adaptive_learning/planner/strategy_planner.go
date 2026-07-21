package planner

import "github.com/pradigi/backend/internal/core/behavior_modeling"

type LearningStrategy string

const (
	StrategyChallenge          LearningStrategy = "CHALLENGE"
	StrategyConfidenceBuilding LearningStrategy = "CONFIDENCE_BUILDING"
	StrategyScaffolding        LearningStrategy = "SCAFFOLDING"
	StrategyCompetition        LearningStrategy = "COMPETITION"
)

// StrategyPlanner determines the pedagogical strategy based on Behavior.
// The Psychologist.
type StrategyPlanner struct{}

func NewStrategyPlanner() *StrategyPlanner {
	return &StrategyPlanner{}
}

func (p *StrategyPlanner) DetermineStrategy(behavior *behavior_modeling.BehaviorProfile) LearningStrategy {
	// Simple deterministic rules for now
	if behavior.Persistence.Current.Value == "High" && behavior.AIDependency.Current.Value == "Low" {
		return StrategyChallenge
	}

	if behavior.Persistence.Current.Value == "Low" && behavior.AIDependency.Current.Value == "High" {
		return StrategyConfidenceBuilding
	}
	
	if behavior.RecoveryCapability.Current.Value == "Poor" {
		return StrategyScaffolding
	}

	return StrategyChallenge // Default
}
