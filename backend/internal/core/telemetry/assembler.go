package telemetry

import (
	"context"
	"encoding/json"

	"github.com/jmoiron/sqlx"
)

type Assembler struct {
	db        *sqlx.DB
	sanitizer *Sanitizer
}

func NewAssembler(db *sqlx.DB, sanitizer *Sanitizer) *Assembler {
	return &Assembler{db: db, sanitizer: sanitizer}
}

// Assemble fetches all relational pieces of an episode and builds the 9-layer JSON
func (a *Assembler) Assemble(ctx context.Context, episodeID string) (map[string]interface{}, error) {
	var ep LearningEpisode
	if err := a.db.GetContext(ctx, &ep, "SELECT * FROM learning_episodes WHERE id = $1", episodeID); err != nil {
		return nil, err
	}

	var events []EpisodeEvent
	if err := a.db.SelectContext(ctx, &events, "SELECT * FROM episode_events WHERE episode_id = $1 ORDER BY timestamp ASC", episodeID); err != nil {
		return nil, err
	}

	var snapshots []EpisodeSnapshot
	if err := a.db.SelectContext(ctx, &snapshots, "SELECT * FROM episode_snapshots WHERE episode_id = $1", episodeID); err != nil {
		return nil, err
	}

	var reflections []EpisodeReflection
	if err := a.db.SelectContext(ctx, &reflections, "SELECT * FROM episode_reflections WHERE episode_id = $1", episodeID); err != nil {
		return nil, err
	}

	var evals []struct {
		GroundTruth string `db:"ground_truth"`
		Evaluation  string `db:"evaluation"`
	}
	_ = a.db.SelectContext(ctx, &evals, "SELECT ground_truth, evaluation FROM episode_evaluations WHERE episode_id = $1", episodeID)

	// Build the 9-Layer JSON
	rawEvents := make([]map[string]interface{}, 0)
	for _, ev := range events {
		var p map[string]interface{}
		_ = json.Unmarshal([]byte(ev.Payload), &p)
		rawEvents = append(rawEvents, map[string]interface{}{
			"id":          ev.ID,
			"event_type":  ev.EventType,
			"timestamp":   ev.Timestamp,
			"duration_ms": ev.DurationMs,
			"payload":     p,
		})
	}

	snapshotMap := make(map[string]interface{})
	for _, snap := range snapshots {
		var d map[string]interface{}
		_ = json.Unmarshal([]byte(snap.Data), &d)
		snapshotMap[snap.SnapshotType] = d
	}

	evaluationLayer := make(map[string]interface{})
	groundTruthLayer := make(map[string]interface{})
	if len(evals) > 0 {
		_ = json.Unmarshal([]byte(evals[0].Evaluation), &evaluationLayer)
		_ = json.Unmarshal([]byte(evals[0].GroundTruth), &groundTruthLayer)
	}

	reflectionLayer := make([]map[string]interface{}, 0)
	for _, ref := range reflections {
		reflectionLayer = append(reflectionLayer, map[string]interface{}{
			"question": ref.Question,
			"answer":   ref.Answer,
		})
	}

	var intentEvo map[string]interface{}
	_ = json.Unmarshal([]byte(ep.IntentEvolution), &intentEvo)

	payload := map[string]interface{}{
		"schema_version":  ep.SchemaVersion,
		"episode_version": ep.EpisodeVersion,
		"Metadata": map[string]interface{}{
			"episode_id":  ep.ID,
			"user_id":     ep.UserID,
			"activity_id": ep.ActivityID,
			"mission_id":  ep.MissionID,
			"created_at":  ep.CreatedAt,
		},
		"Raw Events":          rawEvents,
		"Context":             snapshotMap["context"],
		"Workspace":           snapshotMap["workspace"],
		"Evaluation":          evaluationLayer,
		"Ground Truth":        groundTruthLayer,
		"Reflection":          reflectionLayer,
		"Capability Timeline": snapshotMap["capability_timeline"],
		"Portfolio Evidence":  snapshotMap["portfolio_evidence"],
		"Observer":            snapshotMap["observer"],
		"Intent Evolution":    intentEvo,
	}

	// Apply PII Sanitization
	sanitizedPayload := a.sanitizer.SanitizeMap(payload)
	return sanitizedPayload, nil
}
