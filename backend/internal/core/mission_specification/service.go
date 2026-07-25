package mission_specification

import (
	"context"
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
)

type Service interface {
	RecordActivity(ctx context.Context, cmd RecordActivityCommand) error
}

type RecordActivityCommand struct {
	UserID       string
	TenantID     string
	SourceEngine string
	SourceID     string
	ArtifactID   *string
	ActivityType ActivityType
	Payload      json.RawMessage
}

type service struct {
	repo      Repository
	publisher events.Publisher
}

func NewService(repo Repository, publisher events.Publisher) Service {
	return &service{repo: repo, publisher: publisher}
}

func (s *service) RecordActivity(ctx context.Context, cmd RecordActivityCommand) error {
	a := LearningActivity{
		ID:            ulid.Make().String(),
		UserID:        cmd.UserID,
		TenantID:      cmd.TenantID,
		SourceEngine:  cmd.SourceEngine,
		SourceID:      cmd.SourceID,
		ArtifactID:    cmd.ArtifactID,
		ActivityType:  cmd.ActivityType,
		Payload:       cmd.Payload,
		SchemaVersion: "v1",
		CreatedAt:     time.Now(),
	}

	err := s.repo.CreateActivity(ctx, a)
	if err != nil {
		return err
	}

	eventPayload, _ := json.Marshal(a)
	pubEvent := events.Event{
		ID:            ulid.Make().String(),
		Name:          events.LearningActivityRecorded,
		Priority:      events.PriorityNormal,
		AggregateType: "LearningActivity",
		AggregateID:   a.ID,
		Payload:       eventPayload,
		Metadata: events.Metadata{
			UserID:        cmd.UserID,
			TenantID:      cmd.TenantID,
			SourceEngine:  cmd.SourceEngine,
			SourceVersion: "1.0",
		},
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	}

	s.publisher.Publish(ctx, pubEvent)
	return nil
}
