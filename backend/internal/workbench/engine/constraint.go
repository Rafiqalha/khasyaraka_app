package engine

import (
	"context"
	"time"
)

// ===========================
// Constraint Engine (Separate from Objective Engine)
//
// Objective: "Fix the bug"
// Constraint: "No AI allowed", "Must finish < 20 min", "Cannot modify tests"
//
// Violations produce events. They do NOT stop execution.
// They become part of Mission Summary and Observation.
// ===========================

type ConstraintType string

const (
	ConstraintNoAI          ConstraintType = "NO_AI"
	ConstraintTimeLimit     ConstraintType = "TIME_LIMIT"
	ConstraintNoTestModify  ConstraintType = "NO_TEST_MODIFY"
	ConstraintMaxRuns       ConstraintType = "MAX_RUNS"
	ConstraintMaxHints      ConstraintType = "MAX_HINTS"
	ConstraintNoExternalDocs ConstraintType = "NO_EXTERNAL_DOCS"
)

type Constraint struct {
	Type      ConstraintType `json:"type"`
	Value     any            `json:"value"`     // e.g., 20 for TIME_LIMIT (minutes), 3 for MAX_HINTS
	Enforced  bool           `json:"enforced"`  // Hard constraint (blocks) vs soft (logs only)
}

type ConstraintViolation struct {
	ConstraintType ConstraintType `json:"constraint_type"`
	Message        string         `json:"message"`
	ViolatedAt     time.Time      `json:"violated_at"`
}

type ConstraintEngine struct{}

func NewConstraintEngine() *ConstraintEngine {
	return &ConstraintEngine{}
}

// Check evaluates all constraints against the current session state.
// Returns a list of violations (may be empty).
func (e *ConstraintEngine) Check(
	ctx context.Context,
	constraints []Constraint,
	aiCallCount int,
	runCount int,
	hintCount int,
	elapsedMinutes float64,
	modifiedFiles []string,
) []ConstraintViolation {
	var violations []ConstraintViolation

	for _, c := range constraints {
		switch c.Type {
		case ConstraintNoAI:
			if aiCallCount > 0 {
				violations = append(violations, ConstraintViolation{
					ConstraintType: c.Type,
					Message:        "AI assistance was used but is not allowed for this mission.",
					ViolatedAt:     time.Now(),
				})
			}

		case ConstraintTimeLimit:
			limit, ok := c.Value.(float64)
			if ok && elapsedMinutes > limit {
				violations = append(violations, ConstraintViolation{
					ConstraintType: c.Type,
					Message:        "Time limit exceeded.",
					ViolatedAt:     time.Now(),
				})
			}

		case ConstraintMaxRuns:
			limit, ok := c.Value.(float64)
			if ok && runCount > int(limit) {
				violations = append(violations, ConstraintViolation{
					ConstraintType: c.Type,
					Message:        "Maximum number of code runs exceeded.",
					ViolatedAt:     time.Now(),
				})
			}

		case ConstraintMaxHints:
			limit, ok := c.Value.(float64)
			if ok && hintCount > int(limit) {
				violations = append(violations, ConstraintViolation{
					ConstraintType: c.Type,
					Message:        "Maximum number of hints exceeded.",
					ViolatedAt:     time.Now(),
				})
			}

		case ConstraintNoTestModify:
			for _, f := range modifiedFiles {
				if isTestFile(f) {
					violations = append(violations, ConstraintViolation{
						ConstraintType: c.Type,
						Message:        "Test file was modified but modifications are not allowed.",
						ViolatedAt:     time.Now(),
					})
					break
				}
			}
		}
	}

	return violations
}

func isTestFile(path string) bool {
	return len(path) > 8 && path[len(path)-8:] == "_test.py" ||
		len(path) > 7 && path[len(path)-7:] == "_test.go" ||
		len(path) > 12 && path[:5] == "test_"
}
