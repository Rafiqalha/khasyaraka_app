package workspace

import (
	"encoding/json"
	"time"
)

type Workspace struct {
	ID          string          `db:"id" json:"id"`
	OwnerType   OwnerType       `db:"owner_type" json:"owner_type"`
	OwnerID     string          `db:"owner_id" json:"owner_id"`
	TenantID    string          `db:"tenant_id" json:"tenant_id"`
	Title       string          `db:"title" json:"title"`
	Description string          `db:"description" json:"description"`
	Status      WorkspaceStatus `db:"status" json:"status"`
	CreatedAt   time.Time       `db:"created_at" json:"created_at"`
	UpdatedAt   time.Time       `db:"updated_at" json:"updated_at"`
}

type WorkspaceContext struct {
	ID              string      `db:"id" json:"id"`
	WorkspaceID     string      `db:"workspace_id" json:"workspace_id"`
	ContextType     ContextType `db:"context_type" json:"context_type"`
	ContextID       string      `db:"context_id" json:"context_id"`
	Metadata        json.RawMessage `db:"metadata" json:"metadata"`
	MetadataVersion string      `db:"metadata_version" json:"metadata_version"`
}

type Artifact struct {
	ID                 string             `db:"id" json:"id"`
	WorkspaceID        string             `db:"workspace_id" json:"workspace_id"`
	Title              string             `db:"title" json:"title"`
	ArtifactType       string             `db:"artifact_type" json:"artifact_type"`
	ArtifactState      ArtifactState      `db:"artifact_state" json:"artifact_state"`
	ArtifactVisibility ArtifactVisibility `db:"artifact_visibility" json:"artifact_visibility"`
	ArtifactVersion    int                `db:"artifact_version" json:"artifact_version"`
	StorageType        StorageType        `db:"storage_type" json:"storage_type"`
	StorageRef         string             `db:"storage_ref" json:"storage_ref"`
	Metadata           json.RawMessage    `db:"metadata" json:"metadata"`
	MetadataVersion    string             `db:"metadata_version" json:"metadata_version"`
	CreatedAt          time.Time          `db:"created_at" json:"created_at"`
	UpdatedAt          time.Time          `db:"updated_at" json:"updated_at"`
}



type WorkspaceSnapshot struct {
	ID          string    `db:"id" json:"id"`
	WorkspaceID string    `db:"workspace_id" json:"workspace_id"`
	Title       string    `db:"title" json:"title"`
	Label       string    `db:"label" json:"label"`
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
}

type WorkspaceSnapshotArtifact struct {
	SnapshotID      string `db:"snapshot_id" json:"snapshot_id"`
	ArtifactID      string `db:"artifact_id" json:"artifact_id"`
	ArtifactVersion int    `db:"artifact_version" json:"artifact_version"`
}
