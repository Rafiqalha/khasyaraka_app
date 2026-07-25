package kernel

import (
	"context"
	"encoding/json"
	"time"
)

// ==========================================
// MISSION STATE MACHINE
// ==========================================

// MissionState represents the robust lifecycle of a Mission Runtime
type MissionState string

const (
	StateProvisioning MissionState = "PROVISIONING"
	StateBriefing     MissionState = "BRIEFING"
	StatePlanning     MissionState = "PLANNING"
	StateRunning      MissionState = "RUNNING"
	StateThinking     MissionState = "THINKING"
	StateExecuting    MissionState = "EXECUTING"
	StateReflecting   MissionState = "REFLECTING"
	StateDebrief      MissionState = "DEBRIEF"
	StateCompleted    MissionState = "COMPLETED"
	StatePaused       MissionState = "PAUSED"
	StateError        MissionState = "ERROR"
)

// ==========================================
// EVENT BUS CONTRACT
// ==========================================

// Event represents a continuous event emitted by the Runtime or Plugins.
// It uses an Envelope pattern for robust routing and replayability.
type Event struct {
	ID        string          `json:"id"`
	SessionID string          `json:"session_id"`
	Type      string          `json:"type"`
	Source    string          `json:"source"`
	Timestamp time.Time       `json:"timestamp"`
	Payload   json.RawMessage `json:"payload"`
}

// EventSubscriber defines how components (Capability, Knowledge) listen to events
type EventSubscriber interface {
	OnEvent(ctx context.Context, event Event) error
}

// EventBus is the central nervous system for continuous evidence and telemetry
type EventBus interface {
	Publish(ctx context.Context, event Event) error
	Subscribe(eventType string, subscriber EventSubscriber) error
}

// ==========================================
// KERNEL API & PLUGINS
// ==========================================

// RuntimeSnapshot provides a point-in-time view of the user's state.
// This is read by the Director Engine and other decoupled plugins.
type RuntimeSnapshot struct {
	SessionID           string
	CurrentCapabilities map[string]int
	MissingCapabilities []string
	ProgressPercentage  float64
	RecentEvidence      []Event
}

// RuntimeContext is passed to Plugins so they don't directly couple to the Runtime.
type RuntimeContext interface {
	SessionID() string
	State() MissionState
	Snapshot() RuntimeSnapshot
	Emit(ctx context.Context, eventType string, payload interface{}) error
}

// Plugin represents a Service (e.g., FileService, SandboxService) attached to the Runtime.
// It executes logic using the safe RuntimeContext.
type Plugin interface {
	ID() string
	Initialize(ctx RuntimeContext) error
	Execute(ctx RuntimeContext) error
	Shutdown(ctx RuntimeContext) error
}

// KernelRegistry holds the available plugins that can be mounted based on the Blueprint
type KernelRegistry interface {
	Register(plugin Plugin) error
	Get(pluginID string) (Plugin, error)
}

// MissionRuntime acts as the strict Kernel.
// It orchestrates state, loads plugins via the Registry, and provides the RuntimeContext.
type MissionRuntime interface {
	// Lifecycle
	Start(ctx context.Context) error
	Pause(ctx context.Context) error
	Stop(ctx context.Context) error

	// State Management
	TransitionState(ctx context.Context, newState MissionState) error
	CurrentState() MissionState

	// Plugin Management
	Mount(ctx context.Context, pluginID string) error
	Unmount(ctx context.Context, pluginID string) error

	// Context Provider
	Context() RuntimeContext
}
