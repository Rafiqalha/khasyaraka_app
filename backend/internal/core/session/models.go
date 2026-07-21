package session

import "time"

type LearningSession struct {
	ID          string        `db:"id" json:"id"`
	UserID      string        `db:"user_id" json:"user_id"`
	TenantID    string        `db:"tenant_id" json:"tenant_id"`
	Status      SessionStatus `db:"status" json:"status"`
	StartedAt   time.Time     `db:"started_at" json:"started_at"`
	EndedAt     *time.Time    `db:"ended_at" json:"ended_at,omitempty"`
	DurationSec int           `db:"duration_sec" json:"duration_sec"`
}

type SessionActivity struct {
	SessionID  string `db:"session_id" json:"session_id"`
	ActivityID string `db:"activity_id" json:"activity_id"`
	Sequence   int    `db:"sequence" json:"sequence"`
}
