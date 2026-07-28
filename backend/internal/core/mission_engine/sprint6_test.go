package mission_engine_test

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"
	"time"

	"github.com/pradigi/backend/internal/core/cognitive"
	"github.com/pradigi/backend/internal/core/director"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/core/mission_engine"
)

func TestSprint6LinuxKernelAndTimeMachine(t *testing.T) {
	ctx := context.Background()
	bus := events.NewBus(nil, nil)

	// ==========================================
	// PART 1: LINUX-LIKE MISSION KERNEL AUDIT
	// ==========================================
	t.Log("=== Part 1: Testing Linux-like Mission Kernel (Spawn, Dependency, Checkpoint, Rollback, Fork) ===")
	krn := mission_engine.NewMissionKernel(bus)

	// 1.1 Spawn Parent Process A (No dependencies, max 2 attempts)
	procA, err := krn.Spawn("msn_jwt_auth", "v2.1", []string{}, 2)
	if err != nil || procA.State != mission_engine.ProcessReady {
		t.Fatalf("Expected procA to be READY, got %s (err: %v)", procA.State, err)
	}

	// 1.2 Spawn Dependent Process B (Depends on procA)
	procB, err := krn.Spawn("msn_api_route", "v1.0", []string{procA.PID}, 2)
	if err != nil || procB.State != mission_engine.ProcessQueued {
		t.Fatalf("Expected procB to be QUEUED waiting for dependency, got %s", procB.State)
	}
	t.Logf("[VERIFIED] Dependency Control: Process B (%s) QUEUED waiting for Process A (%s)", procB.PID, procA.PID)

	// 1.3 Checkpoint Process A before risky compile attempt
	stateData := map[string]string{"code_hash": "a1b2c3", "test_passed": "2/5"}
	cp, err := krn.CheckpointProcess(procA.PID, stateData)
	if err != nil || procA.State != mission_engine.ProcessCheckpoint {
		t.Fatalf("Checkpoint failed: %v", err)
	}
	t.Logf("[VERIFIED] Process Checkpointed: ID=%s | StateData=%v", cp.CheckpointID, cp.StateData)

	// 1.4 Simulate Process A crash & first recovery attempt (Retry)
	recoveredProc, err := krn.RecoverProcess(procA.PID)
	if err != nil || recoveredProc.Attempt != 2 || recoveredProc.State != mission_engine.ProcessRecovering {
		t.Fatalf("Expected recovery attempt 2, got attempt %d state %s", recoveredProc.Attempt, recoveredProc.State)
	}
	t.Logf("[VERIFIED] Retry Recovery: Attempt incremented to %d/%d (State: %s)", recoveredProc.Attempt, recoveredProc.MaxAttempts, recoveredProc.State)

	// 1.5 Simulate second crash -> Max attempts exhausted -> Kernel MUST Fork Scaffold Mission!
	forkedProc, err := krn.RecoverProcess(procA.PID)
	if err != nil || forkedProc == nil {
		t.Fatalf("Expected automatic fork upon exhausting max attempts, got err: %v", err)
	}
	if forkedProc.ParentPID != procA.PID || procA.State != mission_engine.ProcessBlocked {
		t.Fatalf("Expected parent %s to be BLOCKED and child forked, got parent state %s", procA.PID, procA.State)
	}
	t.Logf("[VERIFIED] Automatic OS Fork: Max attempts exhausted -> Forked Child PID %s (%s) | Parent BLOCKED",
		forkedProc.PID, forkedProc.MissionID)

	// 1.6 Test Rollback Process to Checkpoint
	err = krn.RollbackProcess(procA.PID, cp.CheckpointID)
	if err != nil || procA.State != mission_engine.ProcessReady {
		t.Fatalf("Rollback failed: %v", err)
	}
	t.Logf("[VERIFIED] Process Rollback: Successfully restored %s to READY from checkpoint %s", procA.PID, cp.CheckpointID)

	// ==========================================
	// PART 2: COGNITIVE TIME MACHINE & DIRECTOR
	// ==========================================
	t.Log("=== Part 2: Testing Cognitive Time Machine (Trajectory Replay) & Mentorship Presenter ===")
	memoryStore := cognitive.NewLearningMemoryStore(bus)

	sessionID := "ses_timemachine_101"
	capability := "stack_trace_reading"

	// 2.1 Simulate historical learning episodes across time
	episodes := []struct {
		signal cognitive.CognitiveSignal
		score  float64
		note   string
		delay  time.Duration
	}{
		{cognitive.SignalGuessing, 0.30, "Trial-and-error guessing on day 1", -72 * time.Hour},
		{cognitive.SignalStruggle, 0.60, "Heavy debugging struggle on day 5", -24 * time.Hour},
		{cognitive.SignalMastery, 0.95, "Verified debugging mastery on day 18", -1 * time.Hour},
	}

	for i, ep := range episodes {
		evd := cognitive.ValidatedEvidence{
			EvidenceID:       fmt.Sprintf("evd_hist_%d", i),
			EpisodeID:        fmt.Sprintf("ep_hist_%d", i),
			SessionID:        sessionID,
			TargetCapability: capability,
			QualityScore:     ep.score,
			Signal:           ep.signal,
			Status:           "ACCEPTED",
			Reason:           ep.note,
		}
		payload, _ := json.Marshal(evd)
		_ = memoryStore.OnEvent(ctx, kernel.Event{Type: cognitive.EventEvidenceValidated, Payload: payload})
	}

	// 2.2 Replay Trajectory using Cognitive Time Machine
	timeMachine := cognitive.NewCognitiveTimeMachine(memoryStore)
	report, err := timeMachine.ReplayTrajectory(capability)
	if err != nil || report == nil {
		t.Fatalf("Trajectory replay failed: %v", err)
	}
	if len(report.TimePoints) != 3 {
		t.Fatalf("Expected 3 chronological points, got %d", len(report.TimePoints))
	}
	t.Logf("[VERIFIED] Cognitive Time Machine Report: Evolution=\"%s\" | Velocity=%.3f/ep", report.ReasoningEvolution, report.Velocity)

	// 2.3 AI Director Presenter Layer Synthesizing Senior Mentorship
	presenter := director.NewMentorshipPresenter()
	// Simulate node where Debugging is < 0.20 to test stack trace guidance synthesis
	mockNode := &cognitive.CognitiveNode{ConceptID: capability, Debugging: 0.15, Reflection: 0.50}
	brief := presenter.SynthesizeBrief(report, mockNode)

	if brief == nil || brief.Today == "" {
		t.Fatal("Expected mentorship brief from presenter")
	}
	t.Logf("[VERIFIED] AI Director Mentorship Output:")
	t.Logf("  * Yesterday: %s", brief.Yesterday)
	t.Logf("  * Today's Mentorship Guidance: \"%s\"", brief.Today)
	t.Logf("  * Risk Analysis: %s", brief.Risk)
	t.Logf("  * Expected Outcome: %s", brief.ExpectedOutcome)
}
