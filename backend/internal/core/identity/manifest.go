package identity

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:       "identity",
	Version:    "1.0",
	Publishes:  []string{"identity.created"}, // Contoh
	Subscribes: []string{},
	DependsOn:     []string{},
	Replayable:    true,
	SourceOfTruth: true,
}
