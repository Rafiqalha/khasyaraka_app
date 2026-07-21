package capability

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:       "capability",
	Version:    "1.0",
	Publishes:  []string{"capability.updated"},
	Subscribes: []string{"mission.completed", "workspace.saved"}, // Contoh
	DependsOn:     []string{"identity"},
	Replayable:    true,
	SourceOfTruth: true,
}
