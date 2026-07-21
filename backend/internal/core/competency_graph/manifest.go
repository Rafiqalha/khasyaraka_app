package competency_graph

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:          "competency_graph",
	Version:       "1.0",
	Publishes:     []string{"competency.delta.recorded", "competency.projected", "competency.snapshot.created"},
	Subscribes:    []string{"evidence.resolved"},
	DependsOn:     []string{"evidence", "skill_ontology", "governance"},
	Replayable:    true,
	SourceOfTruth: false,
}
