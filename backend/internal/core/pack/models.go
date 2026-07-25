package pack

// PackDescriptor is the metadata for a Pack, used by the Registry.
type PackDescriptor struct {
	ID           string `json:"id" yaml:"id"`
	Version      string `json:"version" yaml:"version"`
	Publisher    string `json:"publisher" yaml:"publisher"`
	Source       string `json:"source" yaml:"source"` // e.g. "local", "marketplace"
	BlueprintURI string `json:"blueprint_uri" yaml:"blueprint_uri"`
}

// Capability represents a distinct skill in the Pack's capability graph.
type Capability struct {
	ID           string   `json:"id" yaml:"id"`
	Name         string   `json:"name" yaml:"name"`
	Description  string   `json:"description" yaml:"description"`
	Dependencies []string `json:"dependencies" yaml:"dependencies"`
}

// WorkspaceConfig specifies what UI panels and tools are required/allowed.
type WorkspaceConfig struct {
	Required  []string `json:"required" yaml:"required"`
	Optional  []string `json:"optional" yaml:"optional"`
	Forbidden []string `json:"forbidden" yaml:"forbidden"`
}

// AssessmentPolicy defines the rules for mission success.
type AssessmentPolicy struct {
	PassThresholdConfidence float64  `json:"pass_threshold_confidence" yaml:"pass_threshold_confidence"`
	Rules                   []string `json:"rules" yaml:"rules"`
}

// EvidenceRequirement defines long-term capability acquisition criteria.
type EvidenceRequirement struct {
	Type     string  `json:"type" yaml:"type"`
	MinScore float64 `json:"min_score,omitempty" yaml:"min_score,omitempty"`
	MaxValue float64 `json:"max_value,omitempty" yaml:"max_value,omitempty"`
}

// CapabilityPolicy defines the required evidence stream for capability updates.
type CapabilityPolicy struct {
	RequiredEvidence []EvidenceRequirement `json:"required_evidence" yaml:"required_evidence"`
}

// KnowledgeConfig defines the knowledge boundaries (to prevent LLM hallucination).
type KnowledgeConfig struct {
	Domain string   `json:"domain" yaml:"domain"`
	Topics []string `json:"topics" yaml:"topics"`
}

// TaskBlueprint defines individual action steps inside a mission.
type TaskBlueprint struct {
	ID          string `json:"id" yaml:"id"`
	Title       string `json:"title" yaml:"title"`
	Description string `json:"description" yaml:"description"`
	Order       int    `json:"order" yaml:"order"`
}

// CheckpointBlueprint defines verification milestones inside a mission.
type CheckpointBlueprint struct {
	ID          string `json:"id" yaml:"id"`
	Description string `json:"description" yaml:"description"`
	Type        string `json:"type" yaml:"type"` // e.g. "unit_test", "output_match", "assertion"
}

// MissionBlueprint defines a discrete learning mission inside a Pack.
type MissionBlueprint struct {
	ID           string                `json:"id" yaml:"id"`
	Title        string                `json:"title" yaml:"title"`
	Description  string                `json:"description" yaml:"description"`
	Order        int                   `json:"order" yaml:"order"`
	InitialCode  string                `json:"initial_code,omitempty" yaml:"initial_code,omitempty"`
	Language     string                `json:"language,omitempty" yaml:"language,omitempty"`
	Tasks        []TaskBlueprint       `json:"tasks,omitempty" yaml:"tasks,omitempty"`
	Checkpoints  []CheckpointBlueprint `json:"checkpoints,omitempty" yaml:"checkpoints,omitempty"`
	Dependencies []string              `json:"dependencies,omitempty" yaml:"dependencies,omitempty"`
}

// Pack represents the fully loaded blueprint (murni Go struct, tidak tahu YAML).
type Pack struct {
	Descriptor       PackDescriptor
	Title            string
	Description      string
	Checksum         string
	Capabilities     []Capability
	Workspace        WorkspaceConfig
	Assessment       AssessmentPolicy
	CapabilityPolicy CapabilityPolicy
	Knowledge        KnowledgeConfig
	Missions         []MissionBlueprint
	ReferencesPath   string // URI/Path for the Context Builder to fetch RAG assets
}
