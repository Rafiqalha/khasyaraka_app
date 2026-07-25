package observation

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:          "observation",
	Version:       "1.0",
	Publishes:     []string{"observation.saved", "observation.evidence.extracted"},
	Subscribes:    []string{"activity.aggregated"},
	DependsOn:     []string{"identity", "session", "learning_activity", "events", "activity_aggregator"},
	Replayable:    true,  // Fully replayable from Candidates
	SourceOfTruth: false, // Probabilistic Opini
}
