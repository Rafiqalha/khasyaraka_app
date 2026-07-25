package workspace

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type WorkspaceRepository interface {
	CreateWorkspace(ctx context.Context, w Workspace) error
	GetWorkspace(ctx context.Context, id string) (Workspace, error)
}

type ArtifactRepository interface {
	CreateArtifact(ctx context.Context, a Artifact) error
	GetArtifact(ctx context.Context, id string) (Artifact, error)
}

type SnapshotRepository interface {
	CreateSnapshot(ctx context.Context, s WorkspaceSnapshot) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *repository {
	return &repository{db: db}
}

func (r *repository) CreateWorkspace(ctx context.Context, w Workspace) error {
	query := `
		INSERT INTO workspaces (id, owner_type, owner_id, tenant_id, title, description, status)
		VALUES (:id, :owner_type, :owner_id, :tenant_id, :title, :description, :status)
	`
	_, err := r.db.NamedExecContext(ctx, query, w)
	return err
}

func (r *repository) GetWorkspace(ctx context.Context, id string) (Workspace, error) {
	var w Workspace
	err := r.db.GetContext(ctx, &w, "SELECT * FROM workspaces WHERE id = $1", id)
	return w, err
}

func (r *repository) CreateArtifact(ctx context.Context, a Artifact) error {
	query := `
		INSERT INTO workspace_artifacts (id, workspace_id, title, artifact_type, artifact_state, artifact_visibility, artifact_version, storage_type, storage_ref, metadata, metadata_version)
		VALUES (:id, :workspace_id, :title, :artifact_type, :artifact_state, :artifact_visibility, :artifact_version, :storage_type, :storage_ref, :metadata, :metadata_version)
	`
	_, err := r.db.NamedExecContext(ctx, query, a)
	return err
}

func (r *repository) GetArtifact(ctx context.Context, id string) (Artifact, error) {
	var a Artifact
	err := r.db.GetContext(ctx, &a, "SELECT * FROM workspace_artifacts WHERE id = $1", id)
	return a, err
}

func (r *repository) CreateSnapshot(ctx context.Context, s WorkspaceSnapshot) error {
	query := `
		INSERT INTO workspace_snapshots (id, workspace_id, title, label)
		VALUES (:id, :workspace_id, :title, :label)
	`
	_, err := r.db.NamedExecContext(ctx, query, s)
	return err
}
