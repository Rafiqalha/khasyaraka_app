package workspace

import (
	"context"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
)

type WorkspaceService interface {
	CreateWorkspace(ctx context.Context, cmd CreateWorkspaceCommand) (Workspace, error)
	GetWorkspace(ctx context.Context, id string) (Workspace, error)
}

type CreateWorkspaceCommand struct {
	OwnerType   OwnerType
	OwnerID     string
	TenantID    string
	Title       string
	Description string
}

type workspaceService struct {
	repo      WorkspaceRepository
	publisher events.Publisher
}

func NewWorkspaceService(repo WorkspaceRepository, publisher events.Publisher) WorkspaceService {
	return &workspaceService{repo: repo, publisher: publisher}
}

func (s *workspaceService) CreateWorkspace(ctx context.Context, cmd CreateWorkspaceCommand) (Workspace, error) {
	w := Workspace{
		ID:          ulid.Make().String(),
		OwnerType:   cmd.OwnerType,
		OwnerID:     cmd.OwnerID,
		TenantID:    cmd.TenantID,
		Title:       cmd.Title,
		Description: cmd.Description,
		Status:      StatusActive,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	err := s.repo.CreateWorkspace(ctx, w)
	if err != nil {
		return Workspace{}, err
	}

	// We can publish workspace created event if needed
	return w, nil
}

func (s *workspaceService) GetWorkspace(ctx context.Context, id string) (Workspace, error) {
	return s.repo.GetWorkspace(ctx, id)
}
