// Package session defines the Mission Session model and the Command/Event contracts.
//
// KEY ARCHITECTURAL RULES:
//   1. Session is the SOLE source of all Workbench Events. No other component may emit events.
//   2. Runtime only returns ExecutionResult (fact). It never publishes events.
//   3. Every user intent is expressed as a Command. Every state change is expressed as an Event.
//   4. Mission is immutable. Session is temporal.
package session

import (
	"encoding/json"
	"time"

	"github.com/pradigi/backend/internal/workbench/domain"
)

// ===========================
// Mission Session (Temporal — the running instance of a Mission)
// ===========================

type SessionStatus string

const (
	SessionStatusActive    SessionStatus = "ACTIVE"
	SessionStatusPaused    SessionStatus = "PAUSED"
	SessionStatusCompleted SessionStatus = "COMPLETED"
	SessionStatusAbandoned SessionStatus = "ABANDONED"
	SessionStatusTimedOut  SessionStatus = "TIMED_OUT"
)

type MissionSession struct {
	ID                   string                    `json:"id"`
	UserID               string                    `json:"user_id"`
	ExperimentID         string                    `json:"experiment_id"`
	MissionID            string                    `json:"mission_id"`
	ScenarioID           string                    `json:"scenario_id"`
	Status               SessionStatus             `json:"status"`
	CurrentObjective     string                    `json:"current_objective"`
	CurrentCognitiveState domain.CognitiveStateValue `json:"current_cognitive_state"`
	// Live counters (Mission Summary Projection — updated continuously, not computed at end)
	CompileCount int `json:"compile_count"`
	RunCount     int `json:"run_count"`
	AICallCount  int `json:"ai_call_count"`
	HintCount    int `json:"hint_count"`
	ArtifactCount int `json:"artifact_count"`
	// Timing
	StartedAt   time.Time  `json:"started_at"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
}

// ===========================
// Checkpoint Reason (Why was this snapshot taken?)
// ===========================

type CheckpointReason string

const (
	CheckpointCommand           CheckpointReason = "COMMAND"
	CheckpointMissionCompleted  CheckpointReason = "MISSION_COMPLETED"
	CheckpointObjectiveCompleted CheckpointReason = "OBJECTIVE_COMPLETED"
	CheckpointError             CheckpointReason = "ERROR"
	CheckpointTimeout           CheckpointReason = "TIMEOUT"
	CheckpointAIInteraction     CheckpointReason = "AI_INTERACTION"
	CheckpointConstraintViolated CheckpointReason = "CONSTRAINT_VIOLATED"
)

// ===========================
// Session Snapshot (Cheap replay checkpoints)
// Captured after every significant action (RunCode, AskMentor, etc.)
// Replay doesn't have to start from zero — pick the nearest snapshot.
// ===========================

type SessionSnapshot struct {
	ID                    string                    `json:"id"`
	SessionID             string                    `json:"session_id"`
	Reason                CheckpointReason          `json:"reason"`
	CurrentObjective      string                    `json:"current_objective"`
	CurrentCognitiveState domain.CognitiveStateValue `json:"current_cognitive_state"`
	CurrentFiles          map[string][]byte         `json:"current_files"`
	EnvironmentSnapshotID string                    `json:"environment_snapshot_id"`
	AgentMemoryDump       json.RawMessage           `json:"agent_memory_dump"`
	// Live summary at snapshot time
	CompileCount int `json:"compile_count"`
	RunCount     int `json:"run_count"`
	AICallCount  int `json:"ai_call_count"`
	CapturedAt   time.Time `json:"captured_at"`
}

// ===========================
// Commands (User Intent → Session Orchestrator)
// CQRS: Commands are the write side. Events are the read side.
// ===========================

type CommandType string

const (
	CmdRunCode      CommandType = "RunCode"
	CmdSaveFile     CommandType = "SaveFile"
	CmdOpenFile     CommandType = "OpenFile"
	CmdAskMentor    CommandType = "AskMentor"
	CmdAskQA        CommandType = "AskQA"
	CmdRunTests     CommandType = "RunTests"
	CmdSubmit       CommandType = "Submit"
	CmdAbandon      CommandType = "Abandon"
	CmdCreateArtifact CommandType = "CreateArtifact"
	CmdUpdateArtifact CommandType = "UpdateArtifact"
)

type Command struct {
	ID        string          `json:"id"`
	SessionID string          `json:"session_id"`
	Type      CommandType     `json:"type"`
	Payload   json.RawMessage `json:"payload"`
	IssuedAt  time.Time       `json:"issued_at"`
}

// ===========================
// Workbench Events (ONLY emitted by Session Orchestrator)
// No other component may emit these. Not Runtime. Not Adapter. Not Agent.
// ===========================

type WorkbenchEvent struct {
	ID                 string                   `json:"id"`
	SessionID          string                   `json:"session_id"`
	Type               domain.WorkbenchEventType `json:"type"`
	ActorType          string                   `json:"actor_type"` // "USER", "COMPILER", "MENTOR", "SYSTEM"
	ActorID            string                   `json:"actor_id"`
	Payload            json.RawMessage          `json:"payload"`
	EnvironmentSnapshotID *string               `json:"environment_snapshot_id,omitempty"`
	CognitiveStateAtEvent domain.CognitiveStateValue `json:"cognitive_state_at_event"`
	// Timeline
	RelativeMs int64     `json:"relative_ms"` // Since session start
	OccurredAt time.Time `json:"occurred_at"`
}

// ===========================
// Artifact Version Graph
// Each version records WHO caused the mutation (RunCode, AskMentor, ManualEdit).
// ===========================

type ArtifactEdgeType string

const (
	ArtifactEdgeRunCode    ArtifactEdgeType = "RUN_CODE"
	ArtifactEdgeAskMentor  ArtifactEdgeType = "ASK_MENTOR"
	ArtifactEdgeManualEdit ArtifactEdgeType = "MANUAL_EDIT"
	ArtifactEdgeAutoFix    ArtifactEdgeType = "AUTO_FIX"
	ArtifactEdgeLintFix    ArtifactEdgeType = "LINT_FIX"
)

type ArtifactVersionEdge struct {
	FromVersionID string           `json:"from_version_id"`
	ToVersionID   string           `json:"to_version_id"`
	GeneratedBy   ArtifactEdgeType `json:"generated_by"`
	CommandID     string           `json:"command_id"` // Which command caused this
}
