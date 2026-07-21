package journey

import "time"

// ===========================
// Journey Engine Models (Event Sourcing)
// Tracks the dynamic path a user takes through the static Curriculum.
// ===========================

// Journey represents the progress state of a user through a Curriculum.
type Journey struct {
	ID           string    `json:"id" db:"id"`
	UserID       string    `json:"user_id" db:"user_id"`
	CurriculumID string    `json:"curriculum_id" db:"curriculum_id"`
	Status       string    `json:"status" db:"status"` // "ACTIVE", "COMPLETED"
	ActiveNodeID string    `json:"active_node_id" db:"active_node_id"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`

	// Derived from events, this maps NodeID -> NodeState
	Nodes map[string]NodeState `json:"nodes" db:"-"`
}

type NodeState struct {
	NodeID string    `json:"node_id"`
	Status string    `json:"status"` // "LOCKED", "UNLOCKED", "STARTED", "PAUSED", "COMPLETED"
	XP     int       `json:"xp"`
}

// JourneyEvent acts as the source of truth for all learning progress.
type JourneyEvent struct {
	ID           string    `json:"id" db:"id"`
	JourneyID    string    `json:"journey_id" db:"journey_id"`
	NodeID       *string   `json:"node_id" db:"node_id"`
	Type         EventType `json:"type" db:"type"`
	Payload      string    `json:"payload" db:"payload"`
	Timestamp    time.Time `json:"timestamp" db:"timestamp"`
}

type EventType string

const (
	EventJourneyStarted  EventType = "JourneyStarted"
	EventNodeUnlocked    EventType = "NodeUnlocked"
	EventNodeStarted     EventType = "NodeStarted"
	EventNodePaused      EventType = "NodePaused"
	EventNodeResumed     EventType = "NodeResumed"
	EventNodeCompleted   EventType = "NodeCompleted"
	EventJourneyCompleted EventType = "JourneyCompleted"
)
