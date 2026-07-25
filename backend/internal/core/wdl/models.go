package wdl

// ===========================
// Workspace Definition Language (WDL) Schema
// Inspired by Kubernetes & VSCode Extension Manifests
// ===========================

type APIVersion string

const (
	APIVersionV1Alpha1 APIVersion = "pradigi.io/v1alpha1"
)

type Kind string

const (
	KindWorkspaceDefinition Kind = "WorkspaceDefinition"
)

type WorkspaceManifest struct {
	APIVersion  APIVersion     `yaml:"apiVersion" json:"apiVersion"`
	Kind        Kind           `yaml:"kind" json:"kind"`
	Metadata    Metadata       `yaml:"metadata" json:"metadata"`
	Domain      DomainConfig   `yaml:"domain" json:"domain"`
	Runtime     RuntimeConfig  `yaml:"runtime" json:"runtime"`
	Tools       []ToolDef      `yaml:"tools" json:"tools"`
	Agents      []AgentDef     `yaml:"agents" json:"agents"`
	UI          UILayout       `yaml:"ui" json:"ui"`
	Permissions Permissions    `yaml:"permissions" json:"permissions"`
	Adaptive    AdaptiveConfig `yaml:"adaptive" json:"adaptive"`
}

type Metadata struct {
	ID          string `yaml:"id" json:"id"`           // e.g. "python_debugging"
	Name        string `yaml:"name" json:"name"`       // e.g. "Python Debugging Workspace"
	Version     string `yaml:"version" json:"version"` // e.g. "1.0.0"
	Description string `yaml:"description" json:"description"`
	Icon        string `yaml:"icon" json:"icon"`
	Color       string `yaml:"color" json:"color"`
}

type DomainConfig struct {
	Name             string `yaml:"name" json:"name"`                         // e.g. "python"
	Adapter          string `yaml:"adapter" json:"adapter"`                   // e.g. "plugin://python" or "grpc://localhost:50051"
	CurriculumPath   string `yaml:"curriculumPath" json:"curriculumPath"`     // Relative path to curriculum definitions
	FixturePath      string `yaml:"fixturePath" json:"fixturePath"`           // Relative path to fixtures
	MissionGenerator string `yaml:"missionGenerator" json:"missionGenerator"` // e.g. "deterministic" or "llm_mutator"
}

type RuntimeConfig struct {
	Driver       string   `yaml:"driver" json:"driver"`             // e.g. "docker", "wasm", "kubernetes"
	Image        string   `yaml:"image" json:"image"`               // e.g. "python:3.11-slim"
	Capabilities []string `yaml:"capabilities" json:"capabilities"` // e.g. ["filesystem", "network"]
}

type ToolDef struct {
	Name        string `yaml:"name" json:"name"` // e.g. "editor", "terminal", "wireshark"
	Type        string `yaml:"type" json:"type"` // e.g. "IDE", "CLI", "GUI"
	Description string `yaml:"description" json:"description"`
}

type AgentDef struct {
	Role         string   `yaml:"role" json:"role"`                 // e.g. "mentor", "qa", "reviewer"
	Model        string   `yaml:"model" json:"model"`               // e.g. "deepseek-reasoner"
	Capabilities []string `yaml:"capabilities" json:"capabilities"` // What can this agent do?
}

type UILayout struct {
	Panels []string `yaml:"panels" json:"panels"` // e.g. ["editor", "terminal", "sidebar", "console"]
}

type Permissions struct {
	Filesystem bool `yaml:"filesystem" json:"filesystem"`
	Network    bool `yaml:"network" json:"network"`
	Internet   bool `yaml:"internet" json:"internet"`
	Clipboard  bool `yaml:"clipboard" json:"clipboard"`
}

type AdaptiveConfig struct {
	SupportedStrategies  []string `yaml:"supportedStrategies" json:"supportedStrategies"`
	SupportedConstraints []string `yaml:"supportedConstraints" json:"supportedConstraints"`
	SupportedDifficulty  []string `yaml:"supportedDifficulty" json:"supportedDifficulty"`
}
