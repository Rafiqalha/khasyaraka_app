package orchestrator

import (
	"context"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
)

type Service interface {
	HandleSubsystemProjected(ctx context.Context, subsystem string, evt events.Event) error
}

type service struct {
	repo   Repository
	engine DirectiveEngine
}

func NewService(repo Repository, engine DirectiveEngine) Service {
	return &service{
		repo:   repo,
		engine: engine,
	}
}

func (s *service) HandleSubsystemProjected(ctx context.Context, subsystem string, evt events.Event) error {
	// 1. Update Context (Upsert)
	intelCtx := IntelligenceContext{
		ID:        ulid.Make().String(), // Usually you want to fetch existing or generate new on insert
		UserID:    evt.Metadata.UserID,
		EpochID:   "epoch_v1", // Stand-in
		UpdatedAt: time.Now(),
	}

	switch subsystem {
	case "MEMORY":
		intelCtx.MemoryStateJSON = evt.Payload
	case "ROADMAP":
		intelCtx.RoadmapStateJSON = evt.Payload
	case "CAREER":
		intelCtx.CareerStateJSON = evt.Payload
	case "PORTFOLIO":
		intelCtx.PortfolioStateJSON = evt.Payload
	}

	if err := s.repo.UpsertContext(ctx, intelCtx); err != nil {
		return err
	}

	// 2. We should fetch the FULL updated context from DB to synthesize correctly.
	// For MVP, we pass what we have.
	
	// 3. Synthesize Directive
	directive, err := s.engine.SynthesizeDirective(ctx, intelCtx)
	if err != nil {
		return err
	}

	// 4. Save Directive
	return s.repo.SaveDirective(ctx, *directive)
}
