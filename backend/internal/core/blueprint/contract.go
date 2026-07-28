package blueprint

// PackBlueprint represents the declarative curriculum contract.
// BOUNDARY RULE 1: Blueprint MUST NOT know UI, Flutter, or concrete tools (e.g., editor, terminal).
// It only declares WHAT must be achieved (capability & knowledge targets, required evidence).
type PackBlueprint struct {
	ID                string                 `json:"id" yaml:"id"`
	Version           string                 `json:"version" yaml:"version"`
	Domain            string                 `json:"domain" yaml:"domain"`
	Specialization    string                 `json:"specialization" yaml:"specialization"`
	CapabilityTargets []string               `json:"capability_targets" yaml:"capability_targets"`
	KnowledgeTargets  []string               `json:"knowledge_targets" yaml:"knowledge_targets"`
	EvidenceRequired  []string               `json:"evidence" yaml:"evidence"`
	Constraints       map[string]interface{} `json:"constraints" yaml:"constraints"`
	CompletionPolicy  string                 `json:"completion" yaml:"completion"`
}
