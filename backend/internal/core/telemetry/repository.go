package telemetry

import (
	"context"
	"time"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	CreateEpisode(ctx context.Context, ep *LearningEpisode) error
	LogEvent(ctx context.Context, ev *EpisodeEvent) error
	LogSnapshot(ctx context.Context, snap *EpisodeSnapshot) error
	LogReflection(ctx context.Context, ref *EpisodeReflection) error
}

type LearningEpisode struct {
	ID              string    `db:"id"`
	UserID          string    `db:"user_id"`
	SchemaVersion   string    `db:"schema_version"`
	EpisodeVersion  int       `db:"episode_version"`
	ActivityID      string    `db:"activity_id"`
	MissionID       string    `db:"mission_id"`
	IntentEvolution string    `db:"intent_evolution"` // JSONB
	CreatedAt       time.Time `db:"created_at"`
	UpdatedAt       time.Time `db:"updated_at"`
}

type EpisodeEvent struct {
	ID         string    `db:"id"`
	EpisodeID  string    `db:"episode_id"`
	EventType  string    `db:"event_type"`
	Timestamp  time.Time `db:"timestamp"`
	DurationMs int       `db:"duration_ms"`
	Payload    string    `db:"payload"` // JSONB
	CreatedAt  time.Time `db:"created_at"`
}

type EpisodeSnapshot struct {
	ID           string    `db:"id"`
	EpisodeID    string    `db:"episode_id"`
	SnapshotType string    `db:"snapshot_type"`
	Data         string    `db:"data"` // JSONB
	CreatedAt    time.Time `db:"created_at"`
}

type EpisodeReflection struct {
	ID        string    `db:"id"`
	EpisodeID string    `db:"episode_id"`
	Question  string    `db:"question"`
	Answer    string    `db:"answer"`
	CreatedAt time.Time `db:"created_at"`
}

type repo struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repo{db: db}
}

func (r *repo) CreateEpisode(ctx context.Context, ep *LearningEpisode) error {
	_, err := r.db.NamedExecContext(ctx, `
		INSERT INTO learning_episodes (id, user_id, schema_version, episode_version, activity_id, mission_id, intent_evolution, created_at, updated_at)
		VALUES (:id, :user_id, :schema_version, :episode_version, :activity_id, :mission_id, :intent_evolution, :created_at, :updated_at)
		ON CONFLICT (id) DO UPDATE SET 
			episode_version = learning_episodes.episode_version + 1,
			intent_evolution = :intent_evolution,
			updated_at = :updated_at
	`, ep)
	return err
}

func (r *repo) LogEvent(ctx context.Context, ev *EpisodeEvent) error {
	_, err := r.db.NamedExecContext(ctx, `
		INSERT INTO episode_events (id, episode_id, event_type, timestamp, duration_ms, payload, created_at)
		VALUES (:id, :episode_id, :event_type, :timestamp, :duration_ms, :payload, :created_at)
	`, ev)
	return err
}

func (r *repo) LogSnapshot(ctx context.Context, snap *EpisodeSnapshot) error {
	_, err := r.db.NamedExecContext(ctx, `
		INSERT INTO episode_snapshots (id, episode_id, snapshot_type, data, created_at)
		VALUES (:id, :episode_id, :snapshot_type, :data, :created_at)
	`, snap)
	return err
}

func (r *repo) LogReflection(ctx context.Context, ref *EpisodeReflection) error {
	_, err := r.db.NamedExecContext(ctx, `
		INSERT INTO episode_reflections (id, episode_id, question, answer, created_at)
		VALUES (:id, :episode_id, :question, :answer, :created_at)
	`, ref)
	return err
}
