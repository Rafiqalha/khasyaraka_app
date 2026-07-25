package workspace

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:          "workspace",
	Version:       "1.0",
	Publishes:     []string{"workspace.artifact.saved", "workspace.snapshot.created"},
	Subscribes:    []string{},
	DependsOn:     []string{"identity", "events"},
	Replayable:    true,
	SourceOfTruth: true,
}
