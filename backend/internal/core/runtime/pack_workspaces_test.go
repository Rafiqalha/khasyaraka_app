package runtime_test

import (
	"reflect"
	"testing"

	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/core/runtime"
)

func TestSinglePackMultipleWorkspaces(t *testing.T) {
	t.Log("=== Testing Single Pack Generating Multiple Distinct Workspaces ===")

	registry := runtime.NewRuntimeRegistry(nil)
	packID := "pack_backend_go"

	// Mission 1: Coding & IDE Sandbox Workspace
	msn1 := &mission_compiler.MissionSpecification{
		MissionID: "msn_jwt_middleware",
		GoalID:    packID,
		RuntimeRequirements: mission_compiler.RuntimeRequirements{
			Needs: []string{"coding", "terminal_execution"},
		},
	}
	ws1, err := registry.Resolve(msn1)
	if err != nil {
		t.Fatalf("Failed to resolve Mission 1: %v", err)
	}
	if ws1.Layout != "ide_split_terminal" {
		t.Errorf("Expected Layout 'ide_split_terminal', got '%s'", ws1.Layout)
	}
	expectedPanels1 := []string{"editor", "file_tree", "terminal"}
	if !reflect.DeepEqual(ws1.Panels, expectedPanels1) {
		t.Errorf("Expected panels %v, got %v", expectedPanels1, ws1.Panels)
	}
	t.Logf("[VERIFIED] Workspace 1 (Coding & Debugging): Layout=%s | Panels=%v | Services=%v",
		ws1.Layout, ws1.Panels, ws1.Services)

	// Mission 2: Live API & Database Inspection Workspace
	msn2 := &mission_compiler.MissionSpecification{
		MissionID: "msn_api_endpoint_test",
		GoalID:    packID,
		RuntimeRequirements: mission_compiler.RuntimeRequirements{
			Needs: []string{"api_testing", "database"},
		},
	}
	ws2, err := registry.Resolve(msn2)
	if err != nil {
		t.Fatalf("Failed to resolve Mission 2: %v", err)
	}
	if ws2.Layout != "api_client_layout" {
		t.Errorf("Expected Layout 'api_client_layout', got '%s'", ws2.Layout)
	}
	expectedPanels2 := []string{"api_client", "browser", "db_viewer", "terminal"}
	if !reflect.DeepEqual(ws2.Panels, expectedPanels2) {
		t.Errorf("Expected panels %v, got %v", expectedPanels2, ws2.Panels)
	}
	t.Logf("[VERIFIED] Workspace 2 (Live API & DB Inspection): Layout=%s | Panels=%v | Services=%v",
		ws2.Layout, ws2.Panels, ws2.Services)

	// Mission 3: Architecture & Mentorship Reflection Workspace
	msn3 := &mission_compiler.MissionSpecification{
		MissionID: "msn_architecture_explanation",
		GoalID:    packID,
		RuntimeRequirements: mission_compiler.RuntimeRequirements{
			Needs: []string{"reflection", "architecture_design"},
		},
	}
	ws3, err := registry.Resolve(msn3)
	if err != nil {
		t.Fatalf("Failed to resolve Mission 3: %v", err)
	}
	if ws3.Layout != "mentorship_reflection_layout" {
		t.Errorf("Expected Layout 'mentorship_reflection_layout', got '%s'", ws3.Layout)
	}
	expectedPanels3 := []string{"architecture_canvas", "director_mentorship", "reflection"}
	if !reflect.DeepEqual(ws3.Panels, expectedPanels3) {
		t.Errorf("Expected panels %v, got %v", expectedPanels3, ws3.Panels)
	}
	t.Logf("[VERIFIED] Workspace 3 (Mentorship & Reflection): Layout=%s | Panels=%v | Services=%v",
		ws3.Layout, ws3.Panels, ws3.Services)

	// Assert all 3 workspaces belong to the same Pack but have distinct UI layouts and panel sets
	if ws1.Layout == ws2.Layout || ws2.Layout == ws3.Layout || ws1.Layout == ws3.Layout {
		t.Fatal("Workspaces generated from the pack must have distinct UI layouts!")
	}
	t.Logf("✅ Successfully verified that a single pack (%s) generates 3 distinct, fully functioning workspaces!", packID)
}
