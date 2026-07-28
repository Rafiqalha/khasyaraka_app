package cognitive

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// TelemetryAction represents raw workspace interaction types.
type TelemetryAction string

const (
	ActionCodeEdit    TelemetryAction = "CODE_EDIT"
	ActionCompile     TelemetryAction = "COMPILE"
	ActionTestRun     TelemetryAction = "TEST_RUN"
	ActionTestPass    TelemetryAction = "TEST_PASS"
	ActionTestFail    TelemetryAction = "TEST_FAIL"
	ActionCopy        TelemetryAction = "COPY"
	ActionPaste       TelemetryAction = "PASTE"
	ActionUndo        TelemetryAction = "UNDO"
	ActionRedo        TelemetryAction = "REDO"
	ActionDocView     TelemetryAction = "DOC_VIEW"
	ActionReflection  TelemetryAction = "REFLECTION_SUBMIT"
)

// TelemetryEvent represents a single atomic action in the Cognitive Event Stream.
type TelemetryEvent struct {
	EventID   string          `json:"event_id"`
	SessionID string          `json:"session_id"`
	EpisodeID string          `json:"episode_id"`
	Action    TelemetryAction `json:"action"`
	Payload   string          `json:"payload"`
	Timestamp time.Time       `json:"timestamp"`
}

// CognitiveEpisode represents an aggregated time chunk (e.g., 5 minutes) of user interaction.
// BOUNDARY RULE: Raw telemetry is never sent to the validator. The EpisodeBuilder aggregates it first.
type CognitiveEpisode struct {
	EpisodeID          string    `json:"episode_id"`
	SessionID          string    `json:"session_id"`
	MissionID          string    `json:"mission_id"`
	TargetCapability   string    `json:"target_capability"`
	StartTime          time.Time `json:"start_time"`
	EndTime            time.Time `json:"end_time"`
	DurationSeconds    float64   `json:"duration_seconds"`
	EditCount          int       `json:"edit_count"`
	CompileCount       int       `json:"compile_count"`
	TestPassCount      int       `json:"test_pass_count"`
	TestFailCount      int       `json:"test_fail_count"`
	CopyCount          int       `json:"copy_count"`
	PasteCount         int       `json:"paste_count"`
	UndoCount          int       `json:"undo_count"`
	DocViewCount       int       `json:"doc_view_count"`
	ReflectionSubmitted bool     `json:"reflection_submitted"`
}

const (
	EventEpisodeCompleted = "CognitiveEpisodeCompleted"
)

// EpisodeBuilder processes a stream of raw TelemetryEvents into structured CognitiveEpisodes.
type EpisodeBuilder struct {
	activeEpisodes map[string]*CognitiveEpisode
	bus            kernel.EventBus
	mu             sync.RWMutex
}

func NewEpisodeBuilder(bus kernel.EventBus) *EpisodeBuilder {
	return &EpisodeBuilder{
		activeEpisodes: make(map[string]*CognitiveEpisode),
		bus:            bus,
	}
}

func (e *EpisodeBuilder) StartEpisode(sessionID, missionID, targetCap string) *CognitiveEpisode {
	e.mu.Lock()
	defer e.mu.Unlock()

	epID := fmt.Sprintf("ep_%d", time.Now().UnixNano())
	ep := &CognitiveEpisode{
		EpisodeID:        epID,
		SessionID:        sessionID,
		MissionID:        missionID,
		TargetCapability: targetCap,
		StartTime:        time.Now(),
	}
	e.activeEpisodes[sessionID] = ep
	return ep
}

func (e *EpisodeBuilder) GetActiveEpisode(sessionID string) *CognitiveEpisode {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.activeEpisodes[sessionID]
}

// Ingest processes a raw TelemetryEvent and updates the active CognitiveEpisode.
func (e *EpisodeBuilder) Ingest(ctx context.Context, event TelemetryEvent) error {
	e.mu.Lock()
	ep, exists := e.activeEpisodes[event.SessionID]
	if !exists {
		e.mu.Unlock()
		return fmt.Errorf("no active cognitive episode for session: %s", event.SessionID)
	}

	switch event.Action {
	case ActionCodeEdit:
		ep.EditCount++
	case ActionCompile:
		ep.CompileCount++
	case ActionTestPass:
		ep.TestPassCount++
	case ActionTestFail:
		ep.TestFailCount++
	case ActionCopy:
		ep.CopyCount++
	case ActionPaste:
		ep.PasteCount++
	case ActionUndo:
		ep.UndoCount++
	case ActionDocView:
		ep.DocViewCount++
	case ActionReflection:
		ep.ReflectionSubmitted = true
	}
	e.mu.Unlock()

	logger.Info().Str("session", event.SessionID).Str("action", string(event.Action)).Msg("Ingested telemetry action into active episode")
	return nil
}

// CompleteEpisode finalizes the episode, calculates duration, and emits EventEpisodeCompleted to the Event Bus.
func (e *EpisodeBuilder) CompleteEpisode(ctx context.Context, sessionID string) (*CognitiveEpisode, error) {
	e.mu.Lock()
	ep, exists := e.activeEpisodes[sessionID]
	if !exists {
		e.mu.Unlock()
		return nil, fmt.Errorf("no active cognitive episode for session: %s", sessionID)
	}

	ep.EndTime = time.Now()
	ep.DurationSeconds = ep.EndTime.Sub(ep.StartTime).Seconds()
	delete(e.activeEpisodes, sessionID)
	e.mu.Unlock()

	logger.Info().Str("session", sessionID).Str("episode", ep.EpisodeID).Msg("Cognitive Episode finalized -> Emitting to OS Event Bus")

	if e.bus != nil {
		payloadBytes, _ := json.Marshal(ep)
		busEvent := kernel.Event{
			ID:        fmt.Sprintf("evt_ep_%d", time.Now().UnixNano()),
			SessionID: sessionID,
			Type:      EventEpisodeCompleted,
			Source:    "episode_builder_telemetry_processor",
			Timestamp: time.Now(),
			Payload:   payloadBytes,
		}
		_ = e.bus.Publish(ctx, busEvent)
	}

	return ep, nil
}
