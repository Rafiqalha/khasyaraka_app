package mission

import (
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/adaptive_learning/registry"
	"github.com/pradigi/backend/internal/workbench/domain"
)

// ===========================
// Mission Renderer
// Abstraction layer that takes a Blueprint and a Fixture to generate
// the final Mission struct. This makes the system domain-agnostic.
// ===========================

type MissionRenderer struct{}

func NewMissionRenderer() *MissionRenderer {
	return &MissionRenderer{}
}

func (r *MissionRenderer) Render(bp *MissionBlueprint, fixture *registry.FixtureMetadata) (*domain.Mission, error) {
	// Marshal capabilities
	capsBytes, err := json.Marshal(bp.RequiredCapabilities)
	if err != nil {
		return nil, err
	}

	// Marshal completion conditions (from fixture)
	// In reality, this might involve combining fixture criteria with blueprint constraints
	conditions := map[string]any{
		"pass_tests": true,
		"test_file":  fixture.TestFile,
	}
	condBytes, _ := json.Marshal(conditions)

	mission := &domain.Mission{
		ID:                   ulid.Make().String(),
		Title:                "Fix: " + fixture.BugType,
		Narrative:            fixture.Narrative,
		Domain:               bp.Domain,
		Difficulty:           string(bp.Difficulty),
		AIBudget:             bp.AIBudget,
		RequiredCapabilities: capsBytes,
		CompletionConditions: condBytes,
		CreatedAt:            time.Now(),
	}

	if bp.EstimatedTimeMinutes > 0 {
		limit := bp.EstimatedTimeMinutes * 60
		mission.TimeLimitSec = &limit
	}

	return mission, nil
}
