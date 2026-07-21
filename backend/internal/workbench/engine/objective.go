package engine

import (
	"context"

	"github.com/pradigi/backend/internal/workbench/runtime"
)

// ===========================
// Objective Engine
// Separate from Evaluator. Evaluator answers "what happened?"
// Objective Engine answers "did the user achieve their goal?"
//
// Example: Cyber mission — all tests fail, but the user found the open port.
//          Evaluator says: "tests failed". Objective Engine says: "objective completed".
// ===========================

type ObjectiveStatus struct {
	Completed       bool   `json:"completed"`
	PartialComplete bool   `json:"partial_complete"`
	Reason          string `json:"reason"`
}

type ObjectiveEngine struct{}

func NewObjectiveEngine() *ObjectiveEngine {
	return &ObjectiveEngine{}
}

// Check evaluates whether the current assessment satisfies the given objective.
// This is deterministic logic — no LLM.
func (e *ObjectiveEngine) Check(
	ctx context.Context,
	assessment *runtime.ExecutionAssessment,
	currentObjective string,
) ObjectiveStatus {
	// Default: if all tests pass, objective is completed
	if assessment.AllTestsPassed {
		return ObjectiveStatus{
			Completed: true,
			Reason:    "All tests passed. Objective achieved.",
		}
	}

	// Partial: some tests pass
	if assessment.TestsPassed > 0 {
		return ObjectiveStatus{
			PartialComplete: true,
			Reason:          "Some tests passed. Objective partially achieved.",
		}
	}

	// Syntax errors
	if !assessment.SyntaxValid {
		return ObjectiveStatus{
			Completed: false,
			Reason:    "Code contains syntax errors.",
		}
	}

	// Runtime errors
	if !assessment.RuntimeClean {
		return ObjectiveStatus{
			Completed: false,
			Reason:    "Code raised an unhandled exception.",
		}
	}

	return ObjectiveStatus{
		Completed: false,
		Reason:    "Objective not yet achieved.",
	}
}
