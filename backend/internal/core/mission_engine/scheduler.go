package mission_engine

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// MissionState represents the OS scheduler state machine for a mission instance.
type MissionState string

const (
	StateNotStarted   MissionState = "NOT_STARTED"
	StateInitializing MissionState = "INITIALIZING"
	StateGenerating   MissionState = "GENERATING"
	StateReady        MissionState = "READY"
	StateRunning      MissionState = "RUNNING"
	StateBlocked      MissionState = "BLOCKED"
	StateReflecting   MissionState = "REFLECTING"
	StateCompleted    MissionState = "COMPLETED"
	StateArchived     MissionState = "ARCHIVED"
)

const (
	EventMissionRequested     = "MissionRequested"
	EventMissionInitializing  = "MissionInitializing"
	EventMissionGenerating    = "MissionGenerating"
	EventMissionGenerated     = "MissionGenerated"
	EventMissionReady         = "MissionReady"
	EventWorkspaceProvisioned = "WorkspaceProvisioned"
)

// Scheduler represents the Mission Engine OS Scheduler / State Machine.
// BOUNDARY RULE: Mission Engine MUST NOT call LLMs directly or know about UI/Workspace.
// It is strictly an event-driven state machine managing lifecycle transitions.
type Scheduler struct {
	sessionID string
	state     MissionState
	bus       kernel.EventBus
	spec      *mission_compiler.MissionSpecification
	mu        sync.RWMutex
}

func NewScheduler(sessionID string, bus kernel.EventBus) *Scheduler {
	return &Scheduler{
		sessionID: sessionID,
		state:     StateNotStarted,
		bus:       bus,
	}
}

func (s *Scheduler) CurrentState() MissionState {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.state
}

func (s *Scheduler) Transition(ctx context.Context, newState MissionState) error {
	s.mu.Lock()
	oldState := s.state
	s.state = newState
	s.mu.Unlock()

	logger.Info().Str("session", s.sessionID).Str("from", string(oldState)).Str("to", string(newState)).Msg("OS Scheduler State Transition")
	return nil
}

// StartLifecycle initiates the deterministic mission OS lifecycle.
func (s *Scheduler) StartLifecycle(ctx context.Context, spec *mission_compiler.MissionSpecification) error {
	s.mu.Lock()
	s.spec = spec
	s.mu.Unlock()

	// 1. INITIALIZING
	_ = s.Transition(ctx, StateInitializing)
	_ = s.emitEvent(ctx, EventMissionInitializing, map[string]string{"session_id": s.sessionID, "status": "initializing"})

	// 2. GENERATING -> Request AI Gateway via Event Bus (Zero AI dependency in Engine!)
	_ = s.Transition(ctx, StateGenerating)
	_ = s.emitEvent(ctx, EventMissionGenerating, map[string]string{"session_id": s.sessionID, "status": "generating"})

	payloadBytes, _ := json.Marshal(spec)
	reqEvent := kernel.Event{
		ID:        fmt.Sprintf("evt_req_%d", time.Now().UnixNano()),
		SessionID: s.sessionID,
		Type:      EventMissionRequested,
		Source:    "mission_engine_scheduler",
		Timestamp: time.Now(),
		Payload:   payloadBytes,
	}
	logger.Info().Str("session", s.sessionID).Msg("Scheduler emitting MissionRequested event to OS Event Bus")
	return s.bus.Publish(ctx, reqEvent)
}

// OnEvent handles incoming events from decoupled subscribers (e.g., AI Gateway emitting MissionGenerated).
func (s *Scheduler) OnEvent(ctx context.Context, event kernel.Event) error {
	switch event.Type {
	case EventMissionGenerated:
		logger.Info().Str("session", s.sessionID).Msg("Scheduler received MissionGenerated from Event Bus -> Transitioning to READY")
		_ = s.Transition(ctx, StateReady)
		_ = s.emitEvent(ctx, EventMissionReady, map[string]string{"session_id": s.sessionID, "status": "ready"})
		_ = s.Transition(ctx, StateRunning)
	}
	return nil
}

func (s *Scheduler) emitEvent(ctx context.Context, eventType string, payload interface{}) error {
	payloadBytes, _ := json.Marshal(payload)
	event := kernel.Event{
		ID:        fmt.Sprintf("evt_%d", time.Now().UnixNano()),
		SessionID: s.sessionID,
		Type:      eventType,
		Source:    "mission_engine_scheduler",
		Timestamp: time.Now(),
		Payload:   payloadBytes,
	}
	return s.bus.Publish(ctx, event)
}
