package competency

import "time"

// ProbabilisticDistribution represents a score as a Gaussian distribution.
// This allows the AI to act on uncertainty (confidence intervals).
type ProbabilisticDistribution struct {
	Mean               float64 `json:"mean" db:"mean"`                               // e.g., 85.0
	ConfidenceInterval float64 `json:"confidence_interval" db:"confidence_interval"` // e.g., 4.0 (means 85 ± 4)
}

// CompetencyState represents the rich, multidimensional, probabilistic mastery of a concept.
type CompetencyState struct {
	ConceptID     string                    `json:"concept_id" db:"concept_id"`
	Knowledge     ProbabilisticDistribution `json:"knowledge" db:"knowledge"`         // Recall of facts
	Understanding ProbabilisticDistribution `json:"understanding" db:"understanding"` // Ability to explain
	Application   ProbabilisticDistribution `json:"application" db:"application"`     // Ability to use in missions
	Retention     ProbabilisticDistribution `json:"retention" db:"retention"`         // Memory strength
	Confidence    ProbabilisticDistribution `json:"confidence" db:"confidence"`       // User's self-belief
	LastUpdatedAt time.Time                 `json:"last_updated_at" db:"last_updated_at"`
}

// CompetencyProjection is the fully computed output (including on-the-fly decay)
// representing the current state of a user's abilities.
type CompetencyProjection struct {
	UserID                    string                     `json:"user_id"`
	Concepts                  map[string]CompetencyState `json:"concepts"`
	WeakConcepts              []string                   `json:"weak_concepts"`
	StrongConcepts            []string                   `json:"strong_concepts"`
	PrerequisiteViolations    []string                   `json:"prerequisite_violations"`
	RecommendedConcepts       []string                   `json:"recommended_concepts"`
	EstimatedReadiness        float64                    `json:"estimated_readiness"` // 0-100 readiness for current LO
	NextBestLearningObjective string                     `json:"next_best_learning_objective"`
}
