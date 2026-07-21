// Package domain defines the canonical domain models for the Cognitive Workbench.
// These models are the Contract v1 for the Cognitive Experiment Platform.
// All domain adapters (Python, Cyber, SQL) produce from these types.
package domain

import (
	"encoding/json"
	"time"
)

// ===========================
// Experiment Layer (Research Container)
// ===========================

type Experiment struct {
	ID          string          `db:"id" json:"id"`
	Title       string          `db:"title" json:"title"`
	Description string          `db:"description" json:"description"`
	EpochID     string          `db:"epoch_id" json:"epoch_id"`
	// Research Metadata
	Hypothesis    *string         `db:"hypothesis" json:"hypothesis,omitempty"`
	Variables     json.RawMessage `db:"variables" json:"variables,omitempty"`
	Treatment     json.RawMessage `db:"treatment" json:"treatment,omitempty"`
	Control       json.RawMessage `db:"control" json:"control,omitempty"`
	Metrics       json.RawMessage `db:"metrics" json:"metrics,omitempty"`
	ResearchNotes *string         `db:"research_notes" json:"research_notes,omitempty"`
	Status        string          `db:"status" json:"status"` // DRAFT, ACTIVE, COMPLETED, ARCHIVED
	CreatedAt     time.Time       `db:"created_at" json:"created_at"`
}

// ===========================
// Mission Layer (Objective Container)
// Missions declare CAPABILITIES, not tools.
// Domain Adapters resolve capabilities to actual implementations.
// ===========================

type MissionCapabilityRequirement struct {
	Capability string `json:"capability"` // "code_editor", "terminal", "execution", "mentor"
}

type Mission struct {
	ID           string          `db:"id" json:"id"`
	ExperimentID *string         `db:"experiment_id" json:"experiment_id,omitempty"`
	Title        string          `db:"title" json:"title"`
	Narrative    string          `db:"narrative" json:"narrative"`
	Domain       string          `db:"domain" json:"domain"` // "python", "cybersecurity", "sql"
	Difficulty   string          `db:"difficulty" json:"difficulty"` // EASY, MEDIUM, HARD, EXPERT
	AIBudget     int             `db:"ai_budget" json:"ai_budget"` // Max AI calls allowed
	TimeLimitSec *int            `db:"time_limit_seconds" json:"time_limit_seconds,omitempty"`
	// Capability Declaration - NOT tool specification
	RequiredCapabilities json.RawMessage `db:"required_capabilities" json:"required_capabilities"`
	// Evaluation Contract
	CompletionConditions json.RawMessage `db:"completion_conditions" json:"completion_conditions"`
	PossibleOutcomes     json.RawMessage `db:"possible_outcomes" json:"possible_outcomes"`
	CreatedAt            time.Time       `db:"created_at" json:"created_at"`
}

// ===========================
// Scenario Layer (Variant Container)
// ===========================

type Scenario struct {
	ID              string          `db:"id" json:"id"`
	MissionID       string          `db:"mission_id" json:"mission_id"`
	Title           string          `db:"title" json:"title"`
	InitialStateJSON json.RawMessage `db:"initial_state_json" json:"initial_state_json"`
	Constraints     json.RawMessage `db:"constraints" json:"constraints,omitempty"`
	CreatedAt       time.Time       `db:"created_at" json:"created_at"`
}

// ===========================
// Environment Snapshot (Tree-based)
// Each node is a component of the world.
// Partial replay is supported: only replay "terminal" without reloading the whole state.
// ===========================

type EnvironmentSnapshot struct {
	ID               string          `db:"id" json:"id"`
	SessionID        string          `db:"session_id" json:"session_id"`
	ScenarioID       string          `db:"scenario_id" json:"scenario_id"`
	ParentSnapshotID *string         `db:"parent_snapshot_id" json:"parent_snapshot_id,omitempty"`
	Component        string          `db:"component" json:"component"` // "editor", "console", "terminal", "files", "variables"
	ComponentState   json.RawMessage `db:"component_state_json" json:"component_state_json"`
	CapturedAt       time.Time       `db:"captured_at" json:"captured_at"`
}

// ===========================
// Cognitive Artifacts (Versioned)
// Records the evolution of thinking, not just the final artifact.
// ===========================

type CognitiveArtifact struct {
	ID                string    `db:"id" json:"id"`
	SessionID         string    `db:"session_id" json:"session_id"`
	ArtifactType      string    `db:"artifact_type" json:"artifact_type"` // "scratch_note", "hypothesis", "temp_code"
	Title             *string   `db:"title" json:"title,omitempty"`
	Version           int       `db:"version" json:"version"`
	PreviousVersionID *string   `db:"previous_version_id" json:"previous_version_id,omitempty"`
	Content           string    `db:"content" json:"content"`
	CreatedAt         time.Time `db:"created_at" json:"created_at"`
}

// ===========================
// Decision Graph (Multi-Actor Projection)
// Built FROM Learning Activities, NOT the source of them.
// ===========================

type DecisionGraph struct {
	ID           string          `db:"id" json:"id"`
	SessionID    string          `db:"session_id" json:"session_id"`
	SnapshotJSON json.RawMessage `db:"snapshot_json" json:"snapshot_json"`
	Status       string          `db:"status" json:"status"` // LIVE, SEALED
	UpdatedAt    time.Time       `db:"updated_at" json:"updated_at"`
}

type DecisionNode struct {
	ID                 string          `db:"id" json:"id"`
	GraphID            string          `db:"graph_id" json:"graph_id"`
	ActorType          string          `db:"actor_type" json:"actor_type"` // "USER", "COMPILER", "MENTOR", "LINTER"
	ActorID            *string         `db:"actor_id" json:"actor_id,omitempty"`
	ActionType         string          `db:"action_type" json:"action_type"` // "READ_ERROR", "RUN_CODE", "ASK_MENTOR"
	ContextJSON        json.RawMessage `db:"context_json" json:"context_json,omitempty"`
	OccurredAt         time.Time       `db:"occurred_at" json:"occurred_at"`
	LearningActivityID *string         `db:"learning_activity_id" json:"learning_activity_id,omitempty"`
}

// EdgeType defines the semantic relationship between two decision nodes.
type EdgeType string

const (
	EdgeTypeCauses       EdgeType = "CAUSES"
	EdgeTypeFollows      EdgeType = "FOLLOWS"
	EdgeTypeRetries      EdgeType = "RETRIES"
	EdgeTypeRequestsHelp EdgeType = "REQUESTS_HELP"
	EdgeTypeValidates    EdgeType = "VALIDATES"
	EdgeTypeUndoes       EdgeType = "UNDOES"
	EdgeTypeConfirms     EdgeType = "CONFIRMS"
)

type DecisionEdge struct {
	ID         string   `db:"id" json:"id"`
	GraphID    string   `db:"graph_id" json:"graph_id"`
	FromNodeID string   `db:"from_node_id" json:"from_node_id"`
	ToNodeID   string   `db:"to_node_id" json:"to_node_id"`
	EdgeType   EdgeType `db:"edge_type" json:"edge_type"`
}

// ===========================
// Cognitive State (Finite State Machine)
// A deterministic state machine — NOT an AI opinion.
// Transitions are driven by rules, not LLM calls.
// ===========================

type CognitiveStateValue string

const (
	CognitiveStateExploring   CognitiveStateValue = "EXPLORING"
	CognitiveStateFocused     CognitiveStateValue = "FOCUSED"
	CognitiveStateBlocked     CognitiveStateValue = "BLOCKED"
	CognitiveStateSeekingHelp CognitiveStateValue = "SEEKING_HELP"
	CognitiveStateVerifying   CognitiveStateValue = "VERIFYING"
	CognitiveStateCompleted   CognitiveStateValue = "COMPLETED"
)

type CognitiveState struct {
	ID             string              `db:"id" json:"id"`
	SessionID      string              `db:"session_id" json:"session_id"`
	State          CognitiveStateValue `db:"state" json:"state"`
	PreviousState  *CognitiveStateValue `db:"previous_state" json:"previous_state,omitempty"`
	TriggerEvent   string              `db:"trigger_event" json:"trigger_event"`
	TransitionedAt time.Time           `db:"transitioned_at" json:"transitioned_at"`
}

// ===========================
// Mission Summary (Two-Part: Metrics + Narrative)
// Deterministic facts that feed Observation Candidate.
// ===========================

type MissionSummary struct {
	ID         string    `db:"id" json:"id"`
	SessionID  string    `db:"session_id" json:"session_id"`
	MissionID  string    `db:"mission_id" json:"mission_id"`
	// Metrics
	CompileCount   int    `db:"compile_count" json:"compile_count"`
	RunCount       int    `db:"run_count" json:"run_count"`
	AICalls        int    `db:"ai_calls" json:"ai_calls"`
	HintCount      int    `db:"hint_count" json:"hint_count"`
	ArtifactCount  int    `db:"artifact_count" json:"artifact_count"`
	DurationSeconds int   `db:"duration_seconds" json:"duration_seconds"`
	Outcome        string `db:"outcome" json:"outcome"` // "Solved", "Solved with AI", "Abandoned"
	// Narrative
	MissionDomain       string              `db:"mission_domain" json:"mission_domain"`
	MissionDifficulty   string              `db:"mission_difficulty" json:"mission_difficulty"`
	AIBudgetUsed        int                 `db:"ai_budget_used" json:"ai_budget_used"`
	FinalCognitiveState *CognitiveStateValue `db:"final_cognitive_state" json:"final_cognitive_state,omitempty"`
	// Behavior Summary (The condensed payload for the LLM)
	BehaviorSummaryJSON json.RawMessage     `db:"behavior_summary_json" json:"behavior_summary,omitempty"`
	SealedAt            time.Time           `db:"sealed_at" json:"sealed_at"`
}

// ===========================
// Cognitive Timeline (Visual Trace)
// ===========================

type TimelineEvent struct {
	ID                 string    `db:"id" json:"id"`
	SessionID          string    `db:"session_id" json:"session_id"`
	RelativeMs         int64     `db:"relative_ms" json:"relative_ms"`
	EventType          string    `db:"event_type" json:"event_type"`
	Actor              *string   `db:"actor" json:"actor,omitempty"`
	Summary            string    `db:"summary" json:"summary"` // Human readable
	LearningActivityID *string   `db:"learning_activity_id" json:"learning_activity_id,omitempty"`
	OccurredAt         time.Time `db:"occurred_at" json:"occurred_at"`
}

// ===========================
// Workbench Event Contract (Internal Vocabulary)
// These events are mapped to Learning Activity for Core Platform.
// ===========================

type WorkbenchEventType string

const (
	WBEventMissionStarted      WorkbenchEventType = "MissionStarted"
	WBEventMissionCompleted    WorkbenchEventType = "MissionCompleted"
	WBEventToolRequested       WorkbenchEventType = "ToolRequested"
	WBEventToolExecuted        WorkbenchEventType = "ToolExecuted"
	WBEventToolOutputGenerated WorkbenchEventType = "ToolOutputGenerated"
	WBEventEnvironmentChanged  WorkbenchEventType = "EnvironmentChanged"
	WBEventArtifactCreated     WorkbenchEventType = "ArtifactCreated"
	WBEventArtifactModified    WorkbenchEventType = "ArtifactModified"
	WBEventAgentRequested      WorkbenchEventType = "AgentRequested"
	WBEventAgentResponded      WorkbenchEventType = "AgentResponded"
	WBEventObjectiveCompleted  WorkbenchEventType = "ObjectiveCompleted"
	WBEventConstraintViolated  WorkbenchEventType = "ConstraintViolated"
)
