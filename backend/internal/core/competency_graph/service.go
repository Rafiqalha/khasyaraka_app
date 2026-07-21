package competency_graph

import (
	"context"
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
)

type EventName string

const (
	EventCompetencyDeltaRecorded EventName = "competency.delta.recorded"
	EventCompetencyProjected     EventName = "competency.projected"
	EventCompetencySnapshot      EventName = "competency.snapshot.created"
	EventCompetencyDecayed       EventName = "competency.decayed"
)

type Service interface {
	HandleEvidenceResolved(ctx context.Context, evt events.Event) error
}

type service struct {
	repo        Repository
	publisher   events.Publisher
	scheduler   Scheduler
}

func NewService(repo Repository, publisher events.Publisher, sched Scheduler) Service {
	return &service{
		repo:        repo,
		publisher:   publisher,
		scheduler:   sched,
	}
}

// Evidence payload structure based on evidence model
type EvidencePayload struct {
	ID          string  `json:"id"`
	SkillNodeID string  `json:"skill_node_id"`
	Direction   string  `json:"direction"`
	Strength    float64 `json:"strength"`
	Weight      float64 `json:"weight"`
}

func (s *service) HandleEvidenceResolved(ctx context.Context, evt events.Event) error {
	var ev EvidencePayload
	if err := json.Unmarshal(evt.Payload, &ev); err != nil {
		return err
	}

	// 1. Queue projection job via Scheduler instead of direct computation
	// Using Contribution as the immutable bridge
	err := s.scheduler.QueueJob(ctx, evt.Metadata.UserID, PriorityNormal, "Evidence Resolved: " + ev.ID)
	if err != nil {
		return err
	}
	
	// Create contribution
	c := CompetencyContribution{
		ID: ulid.Make().String(),
		UserID: evt.Metadata.UserID,
		EvidenceID: ev.ID,
		SkillNodeID: ev.SkillNodeID,
		KnowledgeLineageID: "dummy_lineage", // Will be extracted from metadata
		Kind: DeltaObservation,
		Magnitude: ev.Strength,
		Confidence: 1.0,
		Weight: ev.Weight,
		CreatedAt: time.Now(),
	}
	
	if err := s.repo.SaveContribution(ctx, c); err != nil {
		return err
	}

	return nil
}
