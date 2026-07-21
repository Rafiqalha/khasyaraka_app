package roadmap

import (
	"context"
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/memory"
)

type EventName string

const (
	EventRoadmapProjected EventName = "roadmap.projected"
)

type Service interface {
	HandleMemoryProjected(ctx context.Context, evt events.Event) error
}

type service struct {
	repo      Repository
	publisher events.Publisher
	router    AdaptiveRouter
}

func NewService(repo Repository, publisher events.Publisher, router AdaptiveRouter) Service {
	return &service{
		repo:      repo,
		publisher: publisher,
		router:    router,
	}
}

func (s *service) HandleMemoryProjected(ctx context.Context, evt events.Event) error {
	var memProj memory.MemoryProjection
	if err := json.Unmarshal(evt.Payload, &memProj); err != nil {
		return err
	}

	// 1. Adaptive Routing Analysis
	actions, err := s.router.RouteOnMemoryDecay(ctx, memProj.MemoryNodeID, memProj.MemoryState)
	if err != nil || len(actions) == 0 {
		return err // no action needed
	}

	// 2. Create Candidate
	candidate := RoadmapCandidate{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		TriggerType:        "MEMORY_DECAY",
		TriggerRefID:       &memProj.ID,
		KnowledgeLineageID: memProj.KnowledgeLineageID,
		EpochID:            memProj.EpochID,
		Payload:            evt.Payload,
		CreatedAt:          time.Now(),
	}
	if err := s.repo.SaveCandidate(ctx, candidate); err != nil {
		return err
	}

	// 3. Create Events for each Action
	for _, action := range actions {
		actPayload, _ := json.Marshal(action)
		rmEvent := RoadmapEvent{
			ID:                 ulid.Make().String(),
			UserID:             evt.Metadata.UserID,
			CandidateID:        &candidate.ID,
			KnowledgeLineageID: candidate.KnowledgeLineageID,
			EpochID:            candidate.EpochID,
			ActionType:         action.ActionType,
			NodeID:             action.NodeID,
			Payload:            actPayload,
			CreatedAt:          time.Now(),
		}
		if err := s.repo.SaveEvent(ctx, rmEvent); err != nil {
			return err
		}
	}

	// 4. Project new active nodes (Cache)
	proj := RoadmapProjection{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		KnowledgeLineageID: candidate.KnowledgeLineageID,
		EpochID:            candidate.EpochID,
		ActiveNodesJSON:    []byte(`["node_1", "review_` + memProj.MemoryNodeID + `", "node_2"]`),
		Status:             "FRESH",
		ProjectedAt:        time.Now(),
	}
	if err := s.repo.SaveProjection(ctx, proj); err != nil {
		return err
	}

	// Emit Roadmap Projected
	projPayload, _ := json.Marshal(proj)
	s.publisher.Publish(ctx, events.Event{
		ID:            ulid.Make().String(),
		Name:          events.EventName(EventRoadmapProjected),
		Priority:      events.PriorityNormal,
		AggregateType: "RoadmapGraph",
		AggregateID:   proj.ID,
		Payload:       projPayload,
		Metadata:      evt.Metadata,
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	})

	return nil
}
