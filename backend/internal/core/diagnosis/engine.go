package diagnosis

import (
	"github.com/pradigi/backend/internal/core/evidence"
)

// Engine acts as the layer between Raw Evidence and the Competency Engine.
// It analyzes executions to identify specific knowledge gaps.
type Engine struct{}

func NewEngine() *Engine {
	return &Engine{}
}

// Diagnose evaluates an EvidencePackage to find missing prerequisites or misconceptions.
func (e *Engine) Diagnose(evidencePkg *evidence.EvidencePackage) *DiagnosisResult {
	// In a complete implementation, this would:
	// 1. Fetch ExecutionTrace using evidence.ExecutionFingerprint
	// 2. Map trace failures (e.g. infinite loops, index out of bounds)
	// 3. Map failures to KnowledgeGraph concepts

	// Mocking a diagnosis result based on a hypothetical failure
	res := &DiagnosisResult{
		EvidenceID:    evidencePkg.ID,
		OverallStatus: "struggling",
		Gaps: []KnowledgeGap{
			{
				ConceptID:  "loop_boundary",
				Severity:   0.91,
				Confidence: 0.83,
				EvidenceID: evidencePkg.ID,
			},
		},
	}

	return res
}
