package competency_graph

import (
	"encoding/json"
	"time"
)

type DeltaSource string

const (
	DeltaObservation   DeltaSource = "Observation"
	DeltaAssessment    DeltaSource = "Assessment"
	DeltaCertification DeltaSource = "Certification"
	DeltaManualReview  DeltaSource = "ManualReview"
)

// Replaced by CompetencyContribution

type CompetencyProjection struct {
	ID          string           `db:"id" json:"id"`
	UserID      string           `db:"user_id" json:"user_id"`
	SkillNodeID string           `db:"skill_node_id" json:"skill_node_id"`
	Score       float64          `db:"score" json:"score"`
	Status      ProjectionStatus `db:"status" json:"status"`

	GovernanceBundleID string  `db:"governance_bundle_id" json:"governance_bundle_id"`
	RootFingerprint    string  `db:"root_fingerprint" json:"root_fingerprint"`
	SnapshotID         *string `db:"snapshot_id" json:"snapshot_id"`

	Confidence     float64 `db:"confidence" json:"confidence"`
	Trend          string  `db:"trend" json:"trend"`
	Velocity       float64 `db:"velocity" json:"velocity"`
	Stability      string  `db:"stability" json:"stability"`
	Forecast30Days float64 `db:"forecast_30_days" json:"forecast_30_days"`
	Forecast90Days float64 `db:"forecast_90_days" json:"forecast_90_days"`

	MetricsJSON     json.RawMessage `db:"metrics_json" json:"-"`
	ExplanationJSON json.RawMessage `db:"explanation_json" json:"-"`

	ProjectedAt time.Time  `db:"projected_at" json:"projected_at"`
	ExpiresAt   *time.Time `db:"expires_at" json:"expires_at"`
}

type CapabilitySnapshot struct {
	ID        string          `db:"id" json:"id"`
	UserID    string          `db:"user_id" json:"user_id"`
	Manifest  json.RawMessage `db:"manifest" json:"manifest"`
	CreatedAt time.Time       `db:"created_at" json:"created_at"`
}
