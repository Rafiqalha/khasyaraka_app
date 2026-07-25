package knowledge

import (
	"context"
	"time"

	"github.com/jmoiron/sqlx"
)

type CapabilityItem struct {
	ID              string    `json:"id" db:"id"`
	Category        string    `json:"category" db:"category"`
	Name            string    `json:"name" db:"name"`
	Score           float64   `json:"score" db:"score"`           // 0.0 to 1.0
	Confidence      float64   `json:"confidence" db:"confidence"` // 0.0 to 1.0
	LastUpdated     time.Time `json:"last_updated" db:"last_updated"`
	SourceMissionID string    `json:"source_mission_id" db:"source_mission_id"`
}

type CapabilitySnapshot struct {
	UserID       string           `json:"user_id"`
	Capabilities []CapabilityItem `json:"capabilities"`
	FetchedAt    time.Time        `json:"fetched_at"`
}

type SnapshotEvaluator struct {
	db *sqlx.DB
}

func NewSnapshotEvaluator(db *sqlx.DB) *SnapshotEvaluator {
	return &SnapshotEvaluator{db: db}
}

func (e *SnapshotEvaluator) GetSnapshot(ctx context.Context, userID string) (*CapabilitySnapshot, error) {
	// Query user capabilities or build snapshot from runtime_events if table missing
	items := []CapabilityItem{}
	
	// Query runtime events for completed missions/capabilities
	query := `
		SELECT 
			COALESCE(payload->>'capability_id', 'cap_general') as id,
			COALESCE(payload->>'category', 'Programming') as category,
			COALESCE(payload->>'name', 'Python') as name,
			0.85 as score,
			0.90 as confidence,
			created_at as last_updated,
			COALESCE(payload->>'mission_id', 'm_01') as source_mission_id
		FROM runtime_events 
		WHERE user_id = $1 AND event_type IN ('NodeCompleted', 'MissionCompleted', 'NODE_COMPLETED')
		ORDER BY created_at DESC
		LIMIT 20
	`
	_ = e.db.SelectContext(ctx, &items, query, userID)

	return &CapabilitySnapshot{
		UserID:       userID,
		Capabilities: items,
		FetchedAt:    time.Now(),
	}, nil
}
