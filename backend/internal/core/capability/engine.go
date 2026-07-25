package capability

import (
	"context"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// Engine listens to continuous evidence streams and updates capability scores
type Engine struct{}

func NewEngine() *Engine {
	return &Engine{}
}

// OnEvent implements kernel.EventSubscriber
func (e *Engine) OnEvent(ctx context.Context, event kernel.Event) error {
	// Only care about evidence events
	if event.Type != "EVIDENCE_VALIDATED" {
		return nil
	}

	logger.Info().
		Str("session", event.SessionID).
		Str("event_id", event.ID).
		Msg("Capability Engine processing evidence")

	// Decode payload, calculate new competency score, update DB...
	return nil
}
