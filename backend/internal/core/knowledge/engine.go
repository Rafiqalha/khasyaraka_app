package knowledge

import (
	"context"
	"fmt"

	"github.com/hibiken/asynq"
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

type Engine struct{}

func NewEngine() *Engine {
	return &Engine{}
}

// OnEvent implements kernel.EventSubscriber
func (e *Engine) OnEvent(ctx context.Context, event kernel.Event) error {
	logger.Info().
		Str("session", event.SessionID).
		Str("event_id", event.ID).
		Str("type", event.Type).
		Msg("Knowledge Engine received event")

	// Update user's Knowledge Graph in real-time without blocking Runtime
	if event.Type == "MISSION_COMPLETED" {
		fmt.Printf("Updating Knowledge Graph for Session: %s\n", event.SessionID)
	}

	return nil
}

// ProcessEvent processes asynq background tasks for knowledge engine
func (e *Engine) ProcessEvent(ctx context.Context, t *asynq.Task) error {
	logger.Info().
		Str("type", t.Type()).
		Msg("Knowledge Engine processing task")
	return nil
}
