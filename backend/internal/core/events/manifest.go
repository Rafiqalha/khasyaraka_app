package events

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:          "events",
	Version:       "1.0",
	Publishes:     []string{},
	Subscribes:    []string{}, // Technically it routes them
	DependsOn:     []string{},
	Replayable:    true,
	SourceOfTruth: true,
}
