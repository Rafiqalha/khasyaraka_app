// Package evaluation defines the universal Evaluator contract.
// Every domain (Python, Cyber, SQL, Linux) implements this single interface.
// Evaluators consume ExecutionResult (immutable fact) and produce
// ExecutionAssessment (interpretation). The two are never mixed.
package engine

import (
	"context"

	"github.com/pradigi/backend/internal/workbench/runtime"
)

// Evaluator is the universal contract for all domain evaluators.
// Python, Cyber, SQL, Linux evaluators all implement this.
type Evaluator interface {
	// Domain returns the canonical domain identifier.
	Domain() string

	// Assess takes an immutable ExecutionResult and produces an assessment.
	// This is pure logic — no LLM, no AI.
	Assess(ctx context.Context, result *runtime.ExecutionResult) (*runtime.ExecutionAssessment, error)
}
