package runtime_test

import (
	"context"
	"encoding/json"
	"sync"
	"testing"
	"time"

	"github.com/pradigi/backend/internal/core/ai_gateway"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/core/mission_engine"
	"github.com/pradigi/backend/internal/core/runtime"
)

// MockFlutterWorkspace acts as a decoupled UI subscriber listening for WorkspaceManifest events on the OS Event Bus.
type MockFlutterWorkspace struct {
	mu          sync.Mutex
	Received    bool
	Manifest    *runtime.WorkspaceManifest
	DoneChannel chan struct{}
}

func (f *MockFlutterWorkspace) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != mission_engine.EventWorkspaceProvisioned {
		return nil
	}

	var manifest runtime.WorkspaceManifest
	if err := json.Unmarshal(event.Payload, &manifest); err != nil {
		return err
	}

	f.mu.Lock()
	f.Received = true
	f.Manifest = &manifest
	f.mu.Unlock()

	close(f.DoneChannel)
	return nil
}

func TestEventDrivenOSSchedulerPipeline(t *testing.T) {
	ctx := context.Background()

	// 0. Initialize OS Event Bus (The central communication backbone)
	bus := events.NewBus(nil, nil)

	// 1. SPRINT 3.1: Mission Engine OS Scheduler (Zero AI or UI dependency)
	scheduler := mission_engine.NewScheduler("ses_os_loop_001", bus)
	_ = bus.Subscribe(mission_engine.EventMissionGenerated, scheduler)

	// 2. SPRINT 3.2: AI Gateway (Decoupled process subscribing to Scheduler requests)
	gateway := ai_gateway.NewGateway(bus)
	_ = bus.Subscribe(mission_engine.EventMissionRequested, gateway)

	// 3. SPRINT 3.3: Runtime Registry (Plugin Manager subscribing to AI Gateway outputs)
	registry := runtime.NewRuntimeRegistry(bus)
	_ = bus.Subscribe(mission_engine.EventMissionGenerated, registry)

	// 4. SPRINT 3.4: Mock Flutter Workspace (Subscribing to provisioned manifests)
	flutter := &MockFlutterWorkspace{DoneChannel: make(chan struct{})}
	_ = bus.Subscribe(mission_engine.EventWorkspaceProvisioned, flutter)

	// Build a sample specification from compiler
	spec := &mission_compiler.MissionSpecification{
		MissionID: "msn_jwt_adaptive_01",
		GoalID:    "jwt_auth",
		Objective: "Implement JWT expiration middleware",
		RuntimeRequirements: mission_compiler.RuntimeRequirements{
			Needs: []string{"coding", "api_testing", "reflection"},
		},
	}

	t.Log("Starting Mission OS Scheduler lifecycle...")
	startTime := time.Now()

	// Trigger Scheduler -> Emits MissionRequested
	if err := scheduler.StartLifecycle(ctx, spec); err != nil {
		t.Fatalf("Scheduler StartLifecycle failed: %v", err)
	}

	// Wait for asynchronous event propagation across the bus:
	// Scheduler -> EventMissionRequested -> AI Gateway -> EventMissionGenerated -> Runtime Registry -> EventWorkspaceProvisioned -> Flutter
	select {
	case <-flutter.DoneChannel:
		t.Logf("OS Event Bus lifecycle completed in %v", time.Since(startTime))
	case <-time.After(2 * time.Second):
		t.Fatal("Timeout waiting for OS Event Bus pipeline to reach Flutter subscriber")
	}

	// Verify scheduler state transitioned to RUNNING
	if state := scheduler.CurrentState(); state != mission_engine.StateRunning {
		t.Errorf("Expected scheduler state RUNNING, got %s", state)
	}
	t.Logf("Verified OS Scheduler State Machine: %s", scheduler.CurrentState())

	// Verify Flutter received clean, UI-agnostic manifest
	flutter.mu.Lock()
	defer flutter.mu.Unlock()

	if !flutter.Received || flutter.Manifest == nil {
		t.Fatal("Flutter workspace failed to receive WorkspaceManifest")
	}

	t.Logf("Sprint 3.4 Flutter Output - Manifest ID: %s", flutter.Manifest.ManifestID)
	t.Logf("Sprint 3.4 Flutter Output - Layout: %s", flutter.Manifest.Layout)
	t.Logf("Sprint 3.4 Flutter Output - Resolved Panels: %v", flutter.Manifest.Panels)
	t.Logf("Sprint 3.4 Flutter Output - Mounted Services: %v", flutter.Manifest.Services)

	expectedPanels := map[string]bool{"browser": true, "editor": true, "reflection": true, "terminal": true}
	for _, p := range flutter.Manifest.Panels {
		if !expectedPanels[p] {
			t.Errorf("Unexpected panel in manifest: %s", p)
		}
	}
}
