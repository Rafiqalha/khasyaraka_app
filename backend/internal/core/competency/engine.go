package competency

import (
	"time"

	"github.com/pradigi/backend/internal/core/diagnosis"
)

// Engine calculates the user's current competency state dynamically.
type Engine struct {}

func NewEngine() *Engine {
	return &Engine{}
}

// UpdateFromDiagnosis processes a new DiagnosisResult and persists the raw delta.
// In reality, this appends an event to the Competency Event Store.
func (e *Engine) UpdateFromDiagnosis(userID string, diag *diagnosis.DiagnosisResult) error {
	// For example, if there is a gap in "loop_boundary", we log a negative delta.
	// If the status is "passed", we log a positive delta for the target LO.
	return nil
}

// Project computes the on-the-fly CompetencyProjection for a user.
// It loads all past evidence/deltas, calculates decay based on time elapsed,
// and outputs the current effective mastery.
func (e *Engine) Project(userID string) (*CompetencyProjection, error) {
	// Mock implementation
	now := time.Now()
	
	// Imagine we loaded from DB:
	// Base understanding of "iteration" was 100 on Jan 1st.
	// 3 months have passed.
	// We apply a decay curve here.
	
	proj := &CompetencyProjection{
		UserID: userID,
		Concepts: map[string]CompetencyState{
			"iteration": {
				ConceptID:     "iteration",
				Knowledge:     ProbabilisticDistribution{Mean: 95, ConfidenceInterval: 4},
				Understanding: ProbabilisticDistribution{Mean: 82, ConfidenceInterval: 6},
				Application:   ProbabilisticDistribution{Mean: 43, ConfidenceInterval: 12},
				Retention:     ProbabilisticDistribution{Mean: 91, ConfidenceInterval: 3}, // Ebbinghaus factor applied
				Confidence:    ProbabilisticDistribution{Mean: 76, ConfidenceInterval: 8},
				LastUpdatedAt: now,
			},
			"loop_boundary": {
				ConceptID:     "loop_boundary",
				Knowledge:     ProbabilisticDistribution{Mean: 40, ConfidenceInterval: 15}, // Decayed due to recent gaps
				Understanding: ProbabilisticDistribution{Mean: 30, ConfidenceInterval: 18},
				Application:   ProbabilisticDistribution{Mean: 10, ConfidenceInterval: 20},
				Retention:     ProbabilisticDistribution{Mean: 50, ConfidenceInterval: 10},
				Confidence:    ProbabilisticDistribution{Mean: 80, ConfidenceInterval: 5}, // High confidence that the user is weak here
				LastUpdatedAt: now,
			},
		},
		WeakConcepts:            []string{"loop_boundary"},
		StrongConcepts:          []string{"iteration"},
		PrerequisiteViolations:  []string{},
		RecommendedConcepts:     []string{"loop_boundary"},
		EstimatedReadiness:      65.0,
		NextBestLearningObjective: "lo_master_loops",
	}

	return proj, nil
}
