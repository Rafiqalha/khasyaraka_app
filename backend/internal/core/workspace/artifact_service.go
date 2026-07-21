package workspace

import (
	"context"
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
)

type ArtifactService interface {
	SaveArtifact(ctx context.Context, cmd SaveArtifactCommand) (Artifact, error)
}

type SaveArtifactCommand struct {
	WorkspaceID        string
	Title              string
	ArtifactType       string
	ArtifactVisibility ArtifactVisibility
	StorageType        StorageType
	StorageRef         string
	Metadata           json.RawMessage
}

type artifactService struct {
	repo      ArtifactRepository
	publisher events.Publisher
}

func NewArtifactService(repo ArtifactRepository, publisher events.Publisher) ArtifactService {
	return &artifactService{repo: repo, publisher: publisher}
}

func (s *artifactService) SaveArtifact(ctx context.Context, cmd SaveArtifactCommand) (Artifact, error) {
	a := Artifact{
		ID:                 ulid.Make().String(),
		WorkspaceID:        cmd.WorkspaceID,
		Title:              cmd.Title,
		ArtifactType:       cmd.ArtifactType,
		ArtifactState:      ArtifactActive,
		ArtifactVisibility: cmd.ArtifactVisibility,
		ArtifactVersion:    1,
		StorageType:        cmd.StorageType,
		StorageRef:         cmd.StorageRef,
		Metadata:           cmd.Metadata,
		MetadataVersion:    "v1",
		CreatedAt:          time.Now(),
		UpdatedAt:          time.Now(),
	}

	err := s.repo.CreateArtifact(ctx, a)
	if err != nil {
		return Artifact{}, err
	}

	// Publish Artifact Saved Event
	eventPayload, _ := json.Marshal(a)
	pubEvent := events.Event{
		ID:            ulid.Make().String(),
		Name:          events.WorkspaceArtifactSaved,
		Priority:      events.PriorityNormal,
		AggregateType: "WorkspaceArtifact",
		AggregateID:   a.ID,
		Payload:       eventPayload,
		Metadata: events.Metadata{
			SourceEngine:  "WorkspaceEngine",
			SourceVersion: "1.0",
		},
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	}

	s.publisher.Publish(ctx, pubEvent)
	return a, nil
}
