package telemetry

import (
	"strings"
	"time"
)

// LearningDiagnosis - Structured diagnosis produced by TelemetryAnalyzer
type LearningDiagnosis struct {
	Concept        string  `json:"concept"`
	Problem        string  `json:"problem"`
	Difficulty     string  `json:"difficulty"`
	Confidence     float64 `json:"confidence"`
	Recommendation string  `json:"recommendation"`
	FailedRule     string  `json:"failed_rule,omitempty"`
}

// TelemetryInput - Raw runtime telemetry collected during execution
type TelemetryInput struct {
	ConceptID     string        `json:"concept_id"`
	Stderr        string        `json:"stderr"`
	EditCount     int           `json:"edit_count"`
	ExecutionTime time.Duration `json:"execution_time"`
	FailCount     int           `json:"fail_count"`
}

// TelemetryAnalyzer - Parses raw logs into structured LearningDiagnosis JSON
type TelemetryAnalyzer struct{}

func NewTelemetryAnalyzer() *TelemetryAnalyzer {
	return &TelemetryAnalyzer{}
}

func (a *TelemetryAnalyzer) Analyze(input TelemetryInput) *LearningDiagnosis {
	diag := &LearningDiagnosis{
		Concept:        input.ConceptID,
		Problem:        "general_struggle",
		Difficulty:     "normal",
		Confidence:     0.8,
		Recommendation: "guided",
	}

	stderrLower := strings.ToLower(input.Stderr)

	if strings.Contains(stderrLower, "syntaxerror") || strings.Contains(stderrLower, "invalid syntax") {
		diag.Problem = "syntax"
		diag.Recommendation = "guided"
		diag.Confidence = 0.95
	} else if strings.Contains(stderrLower, "indexerror") || strings.Contains(stderrLower, "out of range") {
		diag.Problem = "indexing"
		diag.Recommendation = "visual"
		diag.Confidence = 0.92
	} else if strings.Contains(stderrLower, "typeerror") {
		diag.Problem = "type_mismatch"
		diag.Recommendation = "guided"
		diag.Confidence = 0.90
	} else if strings.Contains(stderrLower, "nameerror") || strings.Contains(stderrLower, "is not defined") {
		diag.Problem = "variable_scope"
		diag.Recommendation = "guided"
		diag.Confidence = 0.88
	}

	if input.FailCount >= 3 {
		diag.Difficulty = "too_high"
		diag.Recommendation = "simplify"
	} else if input.FailCount == 2 {
		diag.Difficulty = "slightly_high"
		diag.Recommendation = "visual"
	}

	return diag
}
