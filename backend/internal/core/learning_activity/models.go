package learning_activity

import (
	"encoding/json"
	"time"
)

type LearningActivity struct {
	ID            string          `db:"id" json:"id"`
	UserID        string          `db:"user_id" json:"user_id"`
	TenantID      string          `db:"tenant_id" json:"tenant_id"`
	SourceEngine  string          `db:"source_engine" json:"source_engine"`
	SourceID      string          `db:"source_id" json:"source_id"`
	ArtifactID    *string         `db:"artifact_id" json:"artifact_id,omitempty"` // nullable
	ActivityType  ActivityType    `db:"activity_type" json:"activity_type"`
	Payload       json.RawMessage `db:"payload" json:"payload"`
	SchemaVersion string          `db:"schema_version" json:"schema_version"`
	CreatedAt     time.Time       `db:"created_at" json:"created_at"`
}
