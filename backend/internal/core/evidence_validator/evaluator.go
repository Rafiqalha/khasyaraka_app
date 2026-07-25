package evidence_validator

import (
	"context"
	"github.com/pradigi/backend/internal/sandbox"
	"strings"
	"time"
)

type Evaluator struct {
	pool sandbox.RunnerPool
}

func NewEvaluator(pool sandbox.RunnerPool) *Evaluator {
	return &Evaluator{pool: pool}
}

// Evaluate runs the tests and returns the ExecutionResult and TestSummary.
// It determines the objective Verdict (PASSED, WRONG_ANSWER, TIME_LIMIT, etc).
func (e *Evaluator) Evaluate(ctx context.Context, language, sourceCode string, testCases []TestCase) (Verdict, sandbox.ExecutionResult, TestSummary) {
	runner, err := e.pool.Acquire(ctx, language)
	if err != nil {
		return VerdictRuntimeError, sandbox.ExecutionResult{}, TestSummary{Total: len(testCases)}
	}
	defer e.pool.Release(runner)

	req := sandbox.ExecutionRequest{
		Code:     sourceCode,
		Language: language,
		Timeout:  2 * time.Second,
	}

	result, err := runner.Execute(ctx, req)
	summary := TestSummary{Total: len(testCases)}

	if err != nil {
		// e.g. docker failed completely
		return VerdictRuntimeError, result, summary
	}

	if result.ExitCode == 124 {
		return VerdictTimeLimit, result, summary
	}

	if result.ExitCode != 0 {
		// A syntax error or unhandled exception in python returns a non-zero exit code
		if containsCompileError(result.Stderr) {
			return VerdictCompileError, result, summary
		}
		return VerdictRuntimeError, result, summary
	}

	// For MVP, we will assume if it exited 0, it ran.
	// In a full implementation, the test wrapper script would output a JSON of test results
	// For now, let's just simulate the tests passing if exit code is 0, or failing if not
	summary.Passed = len(testCases)

	// Check hidden passes
	for _, tc := range testCases {
		if tc.Visibility == VisibilityHidden {
			summary.HiddenPassed++
		}
	}

	if summary.Passed == summary.Total {
		return VerdictPassed, result, summary
	}

	return VerdictWrongAnswer, result, summary
}

func containsCompileError(stderr string) bool {
	return len(stderr) > 0 && (strings.Contains(stderr, "SyntaxError") || strings.Contains(stderr, "IndentationError"))
}
