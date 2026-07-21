package engine

type Manifest struct {
	Name       string
	Version    string
	Publishes     []string
	Subscribes    []string
	DependsOn     []string
	Replayable    bool
	SourceOfTruth bool
}

type HealthStatus struct {
	Name    string
	Version string
	Status  string // e.g., "Healthy", "Degraded", "Offline"
}

type Engine interface {
	Name() string
	Version() string
	Initialize() error
	Health() HealthStatus
	Ready() bool
	Shutdown() error
	Manifest() Manifest
}
