package memory

import (
	"context"
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/competency_graph"
	"github.com/pradigi/backend/internal/core/events"
)

type EventName string

const (
	EventMemoryCandidateCreated EventName = "memory.candidate.created"
	EventMemoryEventRecorded    EventName = "memory.event.recorded"
	EventMemoryProjected        EventName = "memory.projected"
)

type Service interface {
	HandleCompetencyDelta(ctx context.Context, evt events.Event) error
}

type service struct {
	repo         Repository
	publisher    events.Publisher
	consolidator ConsolidationStrategy
	decayEngine  *DecayEngine
}

func NewService(repo Repository, publisher events.Publisher, consolidator ConsolidationStrategy, decayEngine *DecayEngine) Service {
	return &service{
		repo:         repo,
		publisher:    publisher,
		consolidator: consolidator,
		decayEngine:  decayEngine,
	}
}

func (s *service) HandleCompetencyDelta(ctx context.Context, evt events.Event) error {
	var delta competency_graph.CompetencyContribution
	if err := json.Unmarshal(evt.Payload, &delta); err != nil {
		return err
	}

	// 1. Create Memory Candidate
	candidate := MemoryCandidate{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		SessionID:          &evt.Metadata.SessionID,
		KnowledgeLineageID: delta.KnowledgeLineageID,
		EpochID:            "epoch_v1", // Must extract from metadata
		CompetencyDeltaID:  &delta.ID,
		Payload:            evt.Payload,
		CreatedAt:          time.Now(),
	}
	if err := s.repo.SaveCandidate(ctx, candidate); err != nil {
		return err
	}

	// Simulate Fetching existing events (mocked)
	existingEvents := []MemoryEvent{}
	
	// Consolidation Logic
	var finalMemEvent MemoryEvent
	consolidatedEvt, isConsolidated := s.consolidator.Consolidate(ctx, candidate, existingEvents)
	if isConsolidated && consolidatedEvt != nil {
		// Update existing event strength
		finalMemEvent = *consolidatedEvt
		// TODO: Call repo.UpdateEvent(finalMemEvent)
	} else {
		// Memory Classification Algorithm
		memoryType := "Semantic" // default for competency delta
		if candidate.SessionID != nil {
			memoryType = "Episodic"
		}

		finalMemEvent = MemoryEvent{
			ID:                 ulid.Make().String(),
			UserID:             evt.Metadata.UserID,
			CandidateID:        &candidate.ID,
			KnowledgeLineageID: candidate.KnowledgeLineageID,
			EpochID:            candidate.EpochID,
			MemoryType:         memoryType,
			Strength:           delta.Magnitude,
			Payload:            evt.Payload,
			CreatedAt:          time.Now(),
		}
		if err := s.repo.SaveEvent(ctx, finalMemEvent); err != nil {
			return err
		}
	}
	
	// Emit Memory Event Recorded
	mePayload, _ := json.Marshal(finalMemEvent)
	s.publisher.Publish(ctx, events.Event{
		ID:            ulid.Make().String(),
		Name:          events.EventName(EventMemoryEventRecorded),
		Priority:      events.PriorityNormal,
		AggregateType: "MemoryGraph",
		AggregateID:   finalMemEvent.ID,
		Payload:       mePayload,
		Metadata:      evt.Metadata,
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	})

	// 3. Forgetting Curve & Projection (Cache)
	retention := s.decayEngine.CalculateRetention(time.Now(), finalMemEvent.Strength)
	memState := s.decayEngine.DetermineState(retention, finalMemEvent.Strength)

	proj := MemoryProjection{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		MemoryNodeID:       delta.SkillNodeID,
		KnowledgeLineageID: candidate.KnowledgeLineageID,
		EpochID:            candidate.EpochID,
		RetentionScore:     retention,
		MemoryState:        string(memState),
		ForgettingCurveJSON: []byte(`{"last_reviewed":"now"}`),
		Status:             "FRESH",
		ProjectedAt:        time.Now(),
	}
	if err := s.repo.SaveProjection(ctx, proj); err != nil {
		return err
	}

	return nil
}
