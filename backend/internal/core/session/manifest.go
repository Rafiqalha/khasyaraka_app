package session

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:          "session",
	Version:       "1.0",
	Publishes:     []string{"session.started", "session.resumed", "session.paused", "session.ended", "session.rebuilt"},
	Subscribes:    []string{"learning.activity.recorded"},
	DependsOn:     []string{"identity", "events", "learning_activity"},
	Replayable:    true,
	SourceOfTruth: false,
}
