package events

import (
	"encoding/json"
	"time"
)

type EventName string

type EventPriority string

const (
	PriorityHigh   EventPriority = "HIGH"
	PriorityNormal EventPriority = "NORMAL"
	PriorityLow    EventPriority = "LOW"
)

type Metadata struct {
	TenantID      string `json:"tenant_id,omitempty"`
	UserID        string `json:"user_id,omitempty"`
	SessionID     string `json:"session_id,omitempty"`
	RequestID     string `json:"request_id,omitempty"`
	TraceID       string `json:"trace_id,omitempty"`
	CorrelationID string `json:"correlation_id,omitempty"`
	CausationID   string `json:"causation_id,omitempty"`
	SourceEngine  string `json:"source_engine,omitempty"`
	SourceVersion string `json:"source_version,omitempty"`
}

type Event struct {
	ID            string          `json:"id"` // ULID
	Name          EventName       `json:"name"`
	Priority      EventPriority   `json:"priority"`
	AggregateType string          `json:"aggregate_type"`
	AggregateID   string          `json:"aggregate_id"`
	Payload       json.RawMessage `json:"payload"`
	Metadata      Metadata        `json:"metadata"`
	OccurredAt    time.Time       `json:"occurred_at"`
	SchemaVersion string          `json:"schema_version"`
}
