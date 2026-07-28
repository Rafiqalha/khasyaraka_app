package runtime_test

import (
	"testing"

	"github.com/pradigi/backend/internal/core/blueprint"
	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/core/runtime"
)

func TestSprint1AndSprint2Pipeline(t *testing.T) {
	// 1. SPRINT 1: Declarative Blueprint Contract (No UI or tool knowledge)
	bp := &blueprint.PackBlueprint{
		ID:      "backend_go_jwt",
		Version: "2.0.0",
		Domain:  "software_eng",
		CapabilityTargets: []string{
			"jwt_authentication",
			"rest_api",
		},
		KnowledgeTargets: []string{
			"bearer_token",
			"authorization",
		},
		EvidenceRequired: []string{
			"runnable_code",
			"reflection",
		},
		CompletionPolicy: "evidence_based",
	}

	// 2. SPRINT 1: Mission Compiler compiles blueprint into abstract runtime needs (No Flutter/UI knowledge)
	compiler := mission_compiler.NewSpecificationBuilder()
	spec, err := compiler.CompileBlueprint(bp, map[string]int{"jwt_authentication": 65})
	if err != nil {
		t.Fatalf("Failed to compile blueprint: %v", err)
	}

	// Verify specification contains abstract needs without UI names
	expectedNeeds := map[string]bool{
		"coding":      true,
		"api_testing": true,
		"reflection":  true,
	}
	for _, need := range spec.RuntimeRequirements.Needs {
		if !expectedNeeds[need] {
			t.Errorf("Unexpected abstract need: %s", need)
		}
	}
	t.Logf("Sprint 1 Output - Abstract Specification Needs: %v", spec.RuntimeRequirements.Needs)

	// 3. SPRINT 2: Runtime Registry acts as plugin manager (No Pack knowledge)
	registry := runtime.NewRuntimeRegistry(nil)
	workspace, err := registry.Resolve(spec)
	if err != nil {
		t.Fatalf("Failed to resolve workspace: %v", err)
	}

	// Verify resolved concrete workspace panels for Flutter rendering
	t.Logf("Sprint 2 Output - Resolved Concrete Panels: %v", workspace.Panels)
	t.Logf("Sprint 2 Output - Resolved Mounted Services: %v", workspace.Services)

	if len(workspace.Panels) == 0 || len(workspace.Services) == 0 {
		t.Errorf("Expected resolved panels and services, got empty")
	}
}
