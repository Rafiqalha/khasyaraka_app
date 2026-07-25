package mission_specification

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:          "learning_activity",
	Version:       "1.0",
	Publishes:     []string{"learning.activity.recorded"},
	Subscribes:    []string{}, // Observation Engine will subscribe to this
	DependsOn:     []string{"identity", "events"},
	Replayable:    true,
	SourceOfTruth: true,
}
