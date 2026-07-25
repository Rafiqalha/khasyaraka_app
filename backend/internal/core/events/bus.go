package events

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/hibiken/asynq"
	"github.com/jmoiron/sqlx"
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

type EventType string

const (
	EventTypeProfileInitialized EventType = "PROFILE_INITIALIZED"
	EventTypeWorkspaceOpened    EventType = "WORKSPACE_OPENED"

	// Standard Learning OS Lifecycle Events
	EventRuntimeCreated      EventType = "RuntimeCreated"
	EventRuntimeStarted      EventType = "RuntimeStarted"
	EventMissionStarted      EventType = "MissionStarted"
	EventMissionCompleted    EventType = "MissionCompleted"
	EventNodeCompleted       EventType = "NodeCompleted"
	EventCheckpointCompleted EventType = "CheckpointCompleted"
	EventAssessmentCompleted EventType = "AssessmentCompleted"
	EventCapabilityUpdated   EventType = "CapabilityUpdated"
	EventKnowledgeUpdated    EventType = "KnowledgeUpdated"
	EventPortfolioUpdated    EventType = "PortfolioUpdated"
	EventRuntimePaused       EventType = "RuntimePaused"
	EventRuntimeResumed      EventType = "RuntimeResumed"
	EventRuntimeCompleted    EventType = "RuntimeCompleted"
)

type RuntimeEvent struct {
	ID        string          `db:"id" json:"id"`
	UserID    string          `db:"user_id" json:"user_id"`
	NodeID    *string         `db:"node_id" json:"node_id"`
	EventType EventType       `db:"event_type" json:"event_type"`
	Payload   json.RawMessage `db:"payload" json:"payload"`
	CreatedAt time.Time       `db:"created_at" json:"created_at"`
}

type Bus struct {
	db          *sqlx.DB
	asynqClient *asynq.Client
	subscribers []kernel.EventSubscriber
}

func NewBus(db *sqlx.DB, asynqClient *asynq.Client) *Bus {
	return &Bus{
		db:          db,
		asynqClient: asynqClient,
		subscribers: make([]kernel.EventSubscriber, 0),
	}
}

func (b *Bus) Publish(ctx context.Context, event kernel.Event) error {
	logger.Info().Str("event", event.Type).Str("session", event.SessionID).Msg("Event published to bus")
	// Fan out to subscribers (in memory for now, in a real system this goes through Redis/Kafka)
	for _, sub := range b.subscribers {
		go func(subscriber kernel.EventSubscriber) {
			_ = subscriber.OnEvent(context.Background(), event)
		}(sub)
	}
	return nil
}

func (b *Bus) Subscribe(eventType string, subscriber kernel.EventSubscriber) error {
	b.subscribers = append(b.subscribers, subscriber)
	return nil
}

// Emit records the event to PostgreSQL (immutable Event Store) and queues background tasks.
func (b *Bus) Emit(ctx context.Context, userID string, nodeID *string, eventType EventType, payload interface{}) error {
	payloadBytes, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshal payload: %w", err)
	}

	// 1. Record event immutably in PostgreSQL
	query := `
		INSERT INTO runtime_events (user_id, node_id, event_type, payload)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at
	`
	var event RuntimeEvent
	err = b.db.QueryRowContext(ctx, query, userID, nodeID, eventType, payloadBytes).Scan(&event.ID, &event.CreatedAt)
	if err != nil {
		return fmt.Errorf("insert event: %w", err)
	}

	logger.Info().Str("event", string(eventType)).Str("user", userID).Msg("Event emitted")

	// 2. Trigger asynchronous Knowledge Engine processing immediately
	taskPayload, _ := json.Marshal(map[string]interface{}{
		"user_id":    userID,
		"event_id":   event.ID,
		"event_type": eventType,
	})

	task := asynq.NewTask("knowledge:process_event", taskPayload)

	// Enqueue immediately
	_, err = b.asynqClient.EnqueueContext(ctx, task, asynq.Retention(24*time.Hour))
	if err != nil {
		logger.Error().Err(err).Msg("Failed to enqueue knowledge task")
		// We don't fail the primary event emission if Asynq fails
	}

	return nil
}
