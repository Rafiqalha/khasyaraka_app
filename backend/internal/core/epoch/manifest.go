package epoch

import "time"

type KnowledgeManifest struct {
	EpochID               string      `json:"epoch_id"`
	Fingerprint           string      `json:"fingerprint"`
	Contracts             interface{} `json:"contracts"` // For v1, struct
	OntologyVersion       string      `json:"ontology_version"`
	PromptBundleVersion   string      `json:"prompt_bundle_version"`
	ProjectionFormula     string      `json:"projection_formula"`
	GovernanceBundle      string      `json:"governance_bundle"`
	ReplayCertificationID string      `json:"replay_certification_id"`
	BenchmarkResultID     string      `json:"benchmark_result_id"`
	ADRVersion            string      `json:"adr_version"`
	GeneratedAt           time.Time   `json:"generated_at"`
}
