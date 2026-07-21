package workspace

import (
	"context"
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
)

type SnapshotService interface {
	CreateSnapshot(ctx context.Context, cmd CreateSnapshotCommand) (WorkspaceSnapshot, error)
}

type CreateSnapshotCommand struct {
	WorkspaceID string
	Title       string
	Label       string
}

type snapshotService struct {
	repo      SnapshotRepository
	publisher events.Publisher
}

func NewSnapshotService(repo SnapshotRepository, publisher events.Publisher) SnapshotService {
	return &snapshotService{repo: repo, publisher: publisher}
}

func (s *snapshotService) CreateSnapshot(ctx context.Context, cmd CreateSnapshotCommand) (WorkspaceSnapshot, error) {
	snap := WorkspaceSnapshot{
		ID:          ulid.Make().String(),
		WorkspaceID: cmd.WorkspaceID,
		Title:       cmd.Title,
		Label:       cmd.Label,
		CreatedAt:   time.Now(),
	}

	err := s.repo.CreateSnapshot(ctx, snap)
	if err != nil {
		return WorkspaceSnapshot{}, err
	}

	// Publish Event
	eventPayload, _ := json.Marshal(snap)
	pubEvent := events.Event{
		ID:            ulid.Make().String(),
		Name:          events.WorkspaceSnapshotCreated,
		Priority:      events.PriorityNormal,
		AggregateType: "WorkspaceSnapshot",
		AggregateID:   snap.ID,
		Payload:       eventPayload,
		Metadata: events.Metadata{
			SourceEngine:  "WorkspaceEngine",
			SourceVersion: "1.0",
		},
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	}

	s.publisher.Publish(ctx, pubEvent)

	return snap, nil
}
