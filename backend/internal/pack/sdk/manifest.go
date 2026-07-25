package sdk

// Manifest represents the core manifest.yaml inside a .pack archive.
// It contains metadata, compatibility requirements, dependencies, granular sandbox capabilities,
// and default pedagogical strategies.
type Manifest struct {
	PackID          string       `yaml:"pack_id" json:"pack_id"`
	PackType        string       `yaml:"pack_type" json:"pack_type"` // course, toolkit, simulation, etc.
	Version         string       `yaml:"version" json:"version"`     // Semantic versioning, used for Session Pinning
	Title           string       `yaml:"title" json:"title"`
	Author          string       `yaml:"author" json:"author"`
	MinimumRuntime  string       `yaml:"minimum_runtime" json:"minimum_runtime"`
	SDKVersion      string       `yaml:"sdk_version" json:"sdk_version"`
	SupportedModels []string     `yaml:"supported_models" json:"supported_models"`
	Dependencies    []Dependency `yaml:"dependencies" json:"dependencies"`
	Capabilities    Capabilities `yaml:"capabilities" json:"capabilities"`
	Strategies      Strategies   `yaml:"default_strategies" json:"default_strategies"`
}

type Dependency struct {
	PackID  string `yaml:"pack_id" json:"pack_id"`
	Version string `yaml:"version" json:"version"` // Supports semantic ranges e.g. "^1.2.0"
}

// Capabilities define exactly what the sandbox allows this pack to do during runtime execution.
type Capabilities struct {
	Internet   InternetCapability   `yaml:"internet" json:"internet"`
	FileSystem FileSystemCapability `yaml:"filesystem" json:"filesystem"`
	Execution  []string             `yaml:"execution" json:"execution"` // e.g. ["python", "docker-compose"]
}

type InternetCapability struct {
	Whitelist []string `yaml:"whitelist" json:"whitelist"`
	Deny      string   `yaml:"deny" json:"deny"` // e.g. "*"
}

type FileSystemCapability struct {
	ReadOnly []string `yaml:"readonly" json:"readonly"`
	Write    []string `yaml:"write" json:"write"`
}

// Strategies define the macro approach the Adaptive Planner should take by default for different Goal Types.
type Strategies struct {
	Knowledge string `yaml:"knowledge" json:"knowledge"`
	Skill     string `yaml:"skill" json:"skill"`
	Project   string `yaml:"project" json:"project"`
}
