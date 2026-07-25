package director

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// Plugin adapts the Director service to the OS Kernel Plugin architecture
type Plugin struct {
	service *Service
}

func NewPlugin(svc *Service) *Plugin {
	return &Plugin{service: svc}
}

func (p *Plugin) ID() string {
	return "director_service"
}

func (p *Plugin) Initialize(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("Director plugin initialized")
	return nil
}

func (p *Plugin) Execute(ctx kernel.RuntimeContext) error {
	// The Director reads ONLY from the Runtime Snapshot.
	// It knows nothing about the Curriculum or Blueprint.
	snapshot := ctx.Snapshot()

	systemPrompt := `You are Pradigi AI Director. You oversee the user's learning based on their latest Runtime Snapshot.
You MUST output strictly in JSON format matching this schema:
{
  "observation": "What do you observe from their recent performance?",
  "motivation": "A brief coaching tip.",
  "strategy": "A high-level strategy recommendation."
}`

	snapshotBytes, _ := json.Marshal(snapshot)
	userPrompt := fmt.Sprintf("User Runtime Snapshot:\n%s", string(snapshotBytes))

	start := time.Now()
	// Generate JSON using AI client
	jsonStr, _, _, err := p.service.ai.GenerateJSON(context.Background(), systemPrompt, userPrompt)
	if err != nil {
		return fmt.Errorf("director generation failed: %w", err)
	}
	latency := time.Since(start).Milliseconds()

	logger.Info().Str("session", ctx.SessionID()).Int64("latency_ms", latency).Msg("AI Director generated insight")

	// The Director emits an event with its insight back to the Runtime Event Bus
	var payload map[string]interface{}
	_ = json.Unmarshal([]byte(jsonStr), &payload)

	return ctx.Emit(context.Background(), "DIRECTOR_INSIGHT_GENERATED", payload)
}

func (p *Plugin) Shutdown(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("Director plugin shutdown")
	return nil
}
