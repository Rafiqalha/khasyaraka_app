package diagnosis

// KnowledgeGap represents a specific deficiency identified during an execution.
type KnowledgeGap struct {
	ConceptID  string  `json:"concept_id"`
	Severity   float64 `json:"severity"`   // 0.0 to 1.0 (Higher = more critical)
	Confidence float64 `json:"confidence"` // 0.0 to 1.0 (How certain is the engine about this gap)
	EvidenceID string  `json:"evidence_id"`
}

// DiagnosisResult is the output of the DiagnosisEngine.
type DiagnosisResult struct {
	EvidenceID    string         `json:"evidence_id"`
	Gaps          []KnowledgeGap `json:"gaps"`
	OverallStatus string         `json:"overall_status"` // "passed", "failed", "struggling"
}
