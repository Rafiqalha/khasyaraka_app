package cognitive_test

import (
	"context"
	"encoding/json"
	"sync"
	"testing"
	"time"

	"github.com/pradigi/backend/internal/core/cognitive"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/kernel"
)

type MockCapabilityEngine struct {
	mu           sync.Mutex
	LastEvidence *cognitive.ValidatedEvidence
	Received     bool
	DoneChannel  chan struct{}
}

func (m *MockCapabilityEngine) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != cognitive.EventEvidenceValidated && event.Type != cognitive.EventEvidenceRejected {
		return nil
	}

	var evd cognitive.ValidatedEvidence
	if err := json.Unmarshal(event.Payload, &evd); err != nil {
		return err
	}

	m.mu.Lock()
	m.Received = true
	m.LastEvidence = &evd
	m.mu.Unlock()

	select {
	case m.DoneChannel <- struct{}{}:
	default:
	}
	return nil
}

func TestCognitiveTrajectoryLoop(t *testing.T) {
	ctx := context.Background()
	bus := events.NewBus(nil, nil)

	// Initialize SPRINT 4 components
	builder := cognitive.NewEpisodeBuilder(bus)
	validator := cognitive.NewEvidenceValidator(bus)
	_ = bus.Subscribe(cognitive.EventEpisodeCompleted, validator)

	mockCapEngine := &MockCapabilityEngine{DoneChannel: make(chan struct{}, 1)}
	_ = bus.Subscribe("ALL", mockCapEngine)

	// --- TEST CASE 1: COGNITIVE GAMING (COPY-PASTE SPAM) ---
	t.Log("--- Testing Case 1: Cognitive Gaming (Copy-Paste Spam) ---")
	session1 := "ses_game_001"
	builder.StartEpisode(session1, "msn_jwt_01", "jwt_authorization")

	// Stream raw workspace telemetry (User copy pastes without editing)
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session1, Action: cognitive.ActionCopy})
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session1, Action: cognitive.ActionPaste})
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session1, Action: cognitive.ActionPaste})
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session1, Action: cognitive.ActionCompile})

	// Finalize episode -> Triggers Validator via Event Bus
	_, err := builder.CompleteEpisode(ctx, session1)
	if err != nil {
		t.Fatalf("CompleteEpisode failed: %v", err)
	}

	select {
	case <-mockCapEngine.DoneChannel:
	case <-time.After(2 * time.Second):
		t.Fatal("Timeout waiting for Case 1 evidence validation")
	}

	mockCapEngine.mu.Lock()
	evd1 := mockCapEngine.LastEvidence
	mockCapEngine.mu.Unlock()

	if evd1.Status != "REJECTED" || evd1.Signal != cognitive.SignalCopying {
		t.Errorf("Expected REJECTED and COPYING for spam, got %s (%s)", evd1.Status, evd1.Signal)
	}
	t.Logf("Case 1 Result: Quality Score: %.2f | Signal: %s | Status: %s | Reason: %s",
		evd1.QualityScore, evd1.Signal, evd1.Status, evd1.Reason)

	// Reset mock engine state for Case 2
	mockCapEngine.mu.Lock()
	mockCapEngine.LastEvidence = nil
	mockCapEngine.mu.Unlock()
	for len(mockCapEngine.DoneChannel) > 0 {
		<-mockCapEngine.DoneChannel
	}

	// --- TEST CASE 2: TRUE MASTERY TRAJECTORY (DEBUG & REFLECT) ---
	t.Log("--- Testing Case 2: True Mastery Trajectory (Debug & Reflect) ---")
	session2 := "ses_mastery_002"
	builder.StartEpisode(session2, "msn_jwt_02", "jwt_authorization")

	// Stream real learning effort: edit, fail test, edit again, pass test, submit reflection
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session2, Action: cognitive.ActionCodeEdit})
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session2, Action: cognitive.ActionCompile})
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session2, Action: cognitive.ActionTestFail})
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session2, Action: cognitive.ActionCodeEdit})
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session2, Action: cognitive.ActionTestPass})
	_ = builder.Ingest(ctx, cognitive.TelemetryEvent{SessionID: session2, Action: cognitive.ActionReflection})

	_, err = builder.CompleteEpisode(ctx, session2)
	if err != nil {
		t.Fatalf("CompleteEpisode failed for Case 2: %v", err)
	}

	select {
	case <-mockCapEngine.DoneChannel:
	case <-time.After(2 * time.Second):
		t.Fatal("Timeout waiting for Case 2 evidence validation")
	}

	mockCapEngine.mu.Lock()
	evd2 := mockCapEngine.LastEvidence
	mockCapEngine.mu.Unlock()

	if evd2.Status != "ACCEPTED" || evd2.Signal != cognitive.SignalMastery {
		t.Errorf("Expected ACCEPTED and MASTERY for genuine effort, got %s (%s)", evd2.Status, evd2.Signal)
	}
	t.Logf("Case 2 Result: Quality Score: %.2f | Signal: %s | Status: %s | Reason: %s",
		evd2.QualityScore, evd2.Signal, evd2.Status, evd2.Reason)
}
