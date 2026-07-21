package evidence

import "github.com/pradigi/backend/internal/pkg/engine"

var Manifest = engine.Manifest{
	Name:          "evidence",
	Version:       "1.0",
	Publishes:     []string{"evidence.resolved"},
	Subscribes:    []string{"observation.accepted"},
	DependsOn:     []string{"observation", "skill_ontology", "governance"},
	Replayable:    true,
	SourceOfTruth: false,
}
