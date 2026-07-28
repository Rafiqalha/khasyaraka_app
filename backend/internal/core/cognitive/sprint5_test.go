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

type MockDirectorQueue struct {
	mu            sync.Mutex
	LastRec       *cognitive.PlannerRecommendation
	DoneChannel   chan struct{}
}

func (m *MockDirectorQueue) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != cognitive.EventPlannerRecommendationReady {
		return nil
	}

	var rec cognitive.PlannerRecommendation
	if err := json.Unmarshal(event.Payload, &rec); err != nil {
		return err
	}

	m.mu.Lock()
	m.LastRec = &rec
	m.mu.Unlock()

	select {
	case m.DoneChannel <- struct{}{}:
	default:
	}
	return nil
}

func TestSprint5CognitiveGraphAndPlannerPipeline(t *testing.T) {
	ctx := context.Background()
	bus := events.NewBus(nil, nil)

	// 1. Instantiate SPRINT 5 Core Engines
	memoryStore := cognitive.NewLearningMemoryStore(bus)
	capEngine := cognitive.NewCapabilityEngine(bus)
	graph := cognitive.NewCognitiveGraph(bus)
	planner := cognitive.NewSmartPlanner(memoryStore, bus)

	// 2. Wire OS Event Bus Pipeline
	_ = bus.Subscribe(cognitive.EventEvidenceValidated, memoryStore)
	_ = bus.Subscribe(cognitive.EventEvidenceValidated, capEngine)
	_ = bus.Subscribe(cognitive.EventCapabilityDeltaGenerated, graph)
	_ = bus.Subscribe(cognitive.EventCognitiveGraphUpdated, planner)

	mockDirector := &MockDirectorQueue{DoneChannel: make(chan struct{}, 1)}
	_ = bus.Subscribe(cognitive.EventPlannerRecommendationReady, mockDirector)

	// 3. Simulate incoming ValidatedEvidence from Sprint 4 Validator
	t.Log("--- Simulating Sprint 4 Validated Evidence entering Sprint 5 Pipeline ---")
	sessionID := "ses_sprint5_test"
	capability := "jwt_middleware_auth"

	evd := cognitive.ValidatedEvidence{
		EvidenceID:       "evd_test_999",
		EpisodeID:        "ep_001",
		SessionID:        sessionID,
		TargetCapability: capability,
		QualityScore:     0.92,
		Signal:           cognitive.SignalMastery,
		Status:           "ACCEPTED",
		Reason:           "Mastery Proven: debugging & reflection completed",
	}

	payloadBytes, _ := json.Marshal(evd)
	busEvent := kernel.Event{
		ID:        "evt_evd_in",
		SessionID: sessionID,
		Type:      cognitive.EventEvidenceValidated,
		Source:    "test_runner",
		Timestamp: time.Now(),
		Payload:   payloadBytes,
	}

	// Publish to Bus
	err := bus.Publish(ctx, busEvent)
	if err != nil {
		t.Fatalf("Failed to publish validated evidence: %v", err)
	}

	// 4. Wait for multi-hop async pipeline to reach Planner -> Director
	select {
	case <-mockDirector.DoneChannel:
	case <-time.After(3 * time.Second):
		t.Fatal("Timeout waiting for Sprint 5 pipeline to generate Planner Recommendation")
	}

	// 5. Verify Learning Memory (WHY and HOW)
	records := memoryStore.GetRecordsByCapability(capability)
	if len(records) != 1 {
		t.Fatalf("Expected 1 memory record, got %d", len(records))
	}
	if records[0].Signal != cognitive.SignalMastery {
		t.Errorf("Expected memory signal MASTERY, got %s", records[0].Signal)
	}
	t.Logf("[VERIFIED] Learning Memory: Recorded episode narrative (%s)", records[0].BehavioralNote)

	// 6. Verify Cognitive Graph (WHAT multi-dimensional mastery)
	node := graph.GetNode(capability)
	if node == nil {
		t.Fatal("Cognitive Graph node was not created")
	}
	if node.OverallMastery <= 0.0 || node.Implementation <= 0.0 {
		t.Errorf("Expected positive mastery and implementation, got Overall=%.2f Impl=%.2f", node.OverallMastery, node.Implementation)
	}
	t.Logf("[VERIFIED] Cognitive Graph: Concept=%s | Overall Mastery=%.2f%% | Impl=%.2f | Debug=%.2f | Reflect=%.2f",
		node.ConceptID, node.OverallMastery, node.Implementation, node.Debugging, node.Reflection)

	// 7. Verify Smart Planner Recommendation
	mockDirector.mu.Lock()
	rec := mockDirector.LastRec
	mockDirector.mu.Unlock()

	if rec == nil {
		t.Fatal("Expected recommendation from Smart Planner, got nil")
	}
	t.Logf("[VERIFIED] Smart Planner Output: Type=%s | Title=\"%s\" | Rationale=\"%s\"",
		rec.RecommendedType, rec.RecommendedTitle, rec.Rationale)
}
