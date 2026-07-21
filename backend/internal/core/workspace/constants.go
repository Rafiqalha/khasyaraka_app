package workspace

type WorkspaceStatus string

const (
	StatusActive   WorkspaceStatus = "ACTIVE"
	StatusPaused   WorkspaceStatus = "PAUSED"
	StatusArchived WorkspaceStatus = "ARCHIVED"
	StatusLocked   WorkspaceStatus = "LOCKED"
	StatusDeleted  WorkspaceStatus = "DELETED"
)

type OwnerType string

const (
	OwnerUser         OwnerType = "USER"
	OwnerTeam         OwnerType = "TEAM"
	OwnerOrganization OwnerType = "ORGANIZATION"
)

type ContextType string

const (
	ContextMission ContextType = "MISSION"
	ContextAcademy ContextType = "ACADEMY"
	ContextCareer  ContextType = "CAREER"
	ContextSkill   ContextType = "SKILL"
)

type ArtifactState string

const (
	ArtifactActive   ArtifactState = "ACTIVE"
	ArtifactArchived ArtifactState = "ARCHIVED"
	ArtifactDeleted  ArtifactState = "DELETED"
)

type ArtifactVisibility string

const (
	VisibilityPrivate ArtifactVisibility = "PRIVATE"
	VisibilityTeam    ArtifactVisibility = "TEAM"
	VisibilityPublic  ArtifactVisibility = "PUBLIC"
)

type StorageType string

const (
	StoragePostgres      StorageType = "POSTGRES"
	StorageS3            StorageType = "S3"
	StorageObjectStorage StorageType = "OBJECT_STORAGE"
)


