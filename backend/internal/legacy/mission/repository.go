package mission

import (
	"fmt"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) SaveMission(m *Mission) error {
	_, err := r.db.Exec(`
		INSERT INTO missions (id, user_id, persona, objective, narrative, status, score, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		m.ID, m.UserID, m.Persona, m.Objective, m.Narrative, m.Status, m.Score, m.CreatedAt)
	if err != nil {
		return fmt.Errorf("save mission: %w", err)
	}
	return nil
}

func (r *Repository) SaveEvent(missionID string, event EnvironmentEvent) error {
	_, err := r.db.Exec(`
		INSERT INTO mission_events (mission_id, event_type, severity, message, timestamp, server_id, source_ip)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		missionID, event.Type, event.Severity, event.Message, event.Timestamp, event.ServerID, event.SourceIP)
	return err
}
