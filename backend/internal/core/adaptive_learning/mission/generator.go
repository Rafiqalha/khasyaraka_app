package mission

import (
	"github.com/pradigi/backend/internal/core/adaptive_learning/registry"
	"github.com/pradigi/backend/internal/workbench/domain"
)

// ===========================
// Mission Generator (The Builder)
// Currently uses a 100% Deterministic Fixture Registry.
// Future phase: Add Mission Mutator (LLM) to modify fixtures dynamically.
// ===========================

type MissionGenerator struct {
	registry registry.FixtureRegistry
	renderer *MissionRenderer
}

func NewMissionGenerator(reg registry.FixtureRegistry) *MissionGenerator {
	return &MissionGenerator{
		registry: reg,
		renderer: NewMissionRenderer(),
	}
}

// Generate takes a Blueprint and finds a matching Fixture to instantiate a Mission.
func (g *MissionGenerator) Generate(bp *MissionBlueprint) (*domain.Mission, error) {
	// 1. Search for matching fixtures
	// In a real system, we'd pick one randomly or based on history.
	fixtures := g.registry.Search(bp.Domain, string(bp.Difficulty), []string{bp.TargetCompetency})
	
	var selectedFixture registry.FixtureMetadata
	if len(fixtures) > 0 {
		selectedFixture = fixtures[0] // Pick first for now
	} else {
		// Fallback if no exact match (for slice purposes)
		all := g.registry.ListAll()
		if len(all) > 0 {
			selectedFixture = all[0]
		}
	}

	// 2. Render the blueprint and fixture into a concrete Mission
	return g.renderer.Render(bp, &selectedFixture)
}
