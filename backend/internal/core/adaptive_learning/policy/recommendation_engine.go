// Package policy defines adaptive rules and constraints.
// Separates the "what should we do about it" (Recommendation)
// from the "how do we enforce it" (Constraint).
package policy

import "github.com/pradigi/backend/internal/core/behavior_modeling"

type RecommendationType string

const (
	RecReduceAI         RecommendationType = "REDUCE_AI"
	RecIncreaseAI       RecommendationType = "INCREASE_AI"
	RecEnforceTimeLimit RecommendationType = "ENFORCE_TIME_LIMIT"
	RecForceSystematic  RecommendationType = "FORCE_SYSTEMATIC"
	RecBuildConfidence  RecommendationType = "BUILD_CONFIDENCE"
)

type PolicyRecommendation struct {
	Type   RecommendationType `json:"type"`
	Reason string             `json:"reason"`
	Weight float64            `json:"weight"` // 0.0 - 1.0 (How strongly we recommend this)
}

type RecommendationEngine struct{}

func NewRecommendationEngine() *RecommendationEngine {
	return &RecommendationEngine{}
}

// Recommend translates a BehaviorSummary into a list of PolicyRecommendations.
func (e *RecommendationEngine) Recommend(behavior *behavior_modeling.BehaviorSummary) []PolicyRecommendation {
	var recs []PolicyRecommendation

	if behavior.AIDependencyLevel == "High" {
		recs = append(recs, PolicyRecommendation{
			Type:   RecReduceAI,
			Reason: "User has high AI dependency. Force independent problem solving.",
			Weight: 0.9,
		})
	}

	if behavior.PrimaryStrategy == string(behavior_modeling.StrategyTrialError) && behavior.PersistenceLevel == "Low" {
		recs = append(recs, PolicyRecommendation{
			Type:   RecForceSystematic,
			Reason: "User is guessing and giving up easily. Restrict rapid runs.",
			Weight: 0.85,
		})
	}
	
	if behavior.PersistenceLevel == "Low" && behavior.RecoveryCapability == "Poor" {
		recs = append(recs, PolicyRecommendation{
			Type:   RecBuildConfidence,
			Reason: "User struggles to recover and abandons early. Need easier wins.",
			Weight: 0.95,
		})
	}

	return recs
}
