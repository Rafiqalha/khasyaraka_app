package aggregation

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:          "activity_aggregator",
	Version:       "1.0",
	Publishes:     []string{"activity.aggregated"},
	Subscribes:    []string{"learning.activity.recorded", "session.ended"},
	DependsOn:     []string{"session", "learning_activity", "events"},
	Replayable:    true,
	SourceOfTruth: false,
}
