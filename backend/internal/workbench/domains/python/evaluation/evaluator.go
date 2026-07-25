// Package evaluation implements the Python-specific evaluator.
// It implements the universal workbench/engine.Evaluator interface.
package evaluation

import (
	"context"

	wbengine "github.com/pradigi/backend/internal/workbench/engine"
	"github.com/pradigi/backend/internal/workbench/runtime"
)

// PythonEvaluator implements wbengine.Evaluator for the Python domain.
type PythonEvaluator struct{}

// Ensure PythonEvaluator implements the universal contract at compile time.
var _ wbengine.Evaluator = (*PythonEvaluator)(nil)

func NewEvaluator() *PythonEvaluator {
	return &PythonEvaluator{}
}

func (e *PythonEvaluator) Domain() string { return "python" }

// Assess consumes an immutable ExecutionResult and produces an ExecutionAssessment.
// This is pure deterministic logic — no LLM, no AI.
func (e *PythonEvaluator) Assess(ctx context.Context, result *runtime.ExecutionResult) (*runtime.ExecutionAssessment, error) {
	assessment := &runtime.ExecutionAssessment{
		RequestID: result.RequestID,
		TimedOut:  result.TimedOut,
		OOMKilled: result.OOMKilled,
	}

	// Syntax check
	if result.ExitCode == 0 || result.Stderr == "" {
		assessment.SyntaxValid = true
	}

	// Runtime check
	if result.ExitCode == 0 {
		assessment.RuntimeClean = true
	}

	// Test results
	assessment.TestsPassed = result.TestsPassed
	assessment.TestsFailed = result.TestsFailed
	if result.TestsTotal > 0 && result.TestsFailed == 0 {
		assessment.AllTestsPassed = true
	}

	// Build summary
	switch {
	case result.TimedOut:
		assessment.Summary = "Execution timed out. Code may contain an infinite loop or excessive computation."
	case result.OOMKilled:
		assessment.Summary = "Execution ran out of memory. Check for unbounded data structures."
	case !assessment.SyntaxValid:
		assessment.Summary = "Code contains syntax errors. Review the error message in stderr."
	case !assessment.RuntimeClean:
		assessment.Summary = "Code raised an unhandled exception during execution."
	case assessment.AllTestsPassed:
		assessment.Summary = "All tests passed. The bug has been successfully fixed."
	case result.TestsTotal > 0:
		assessment.Summary = "Some tests failed. The fix is incomplete."
	default:
		assessment.Summary = "Code executed successfully but no test suite was provided."
	}

	return assessment, nil
}
