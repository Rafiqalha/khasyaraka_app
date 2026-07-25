package observation

import (
	"encoding/json"
	"time"
)

type ModelRegistry struct {
	ID        string    `db:"id" json:"id"`
	Name      string    `db:"name" json:"name"`
	Provider  string    `db:"provider" json:"provider"`
	Version   string    `db:"version" json:"version"`
	CreatedAt time.Time `db:"created_at" json:"created_at"`
}

type InferenceProfile struct {
	ID          string    `db:"id" json:"id"`
	ModelID     string    `db:"model_id" json:"model_id"`
	Name        string    `db:"name" json:"name"`
	Temperature float64   `db:"temperature" json:"temperature"`
	TopP        float64   `db:"top_p" json:"top_p"`
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
}

type PromptAsset struct {
	ID        string    `db:"id" json:"id"`
	Name      string    `db:"name" json:"name"`
	Version   string    `db:"version" json:"version"`
	Hash      string    `db:"hash" json:"hash"`
	CreatedAt time.Time `db:"created_at" json:"created_at"`
}

type PromptBundle struct {
	ID        string    `db:"id" json:"id"`
	Name      string    `db:"name" json:"name"`
	Version   string    `db:"version" json:"version"`
	Hash      string    `db:"hash" json:"hash"`
	CreatedAt time.Time `db:"created_at" json:"created_at"`
}

type ObservationCandidate struct {
	ID          string    `db:"id" json:"id"`
	SessionID   string    `db:"session_id" json:"session_id"`
	Fingerprint string    `db:"fingerprint" json:"fingerprint"` // Hash of references
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
}

type ValidationReport struct {
	ID            string    `db:"id" json:"id"`
	ObservationID string    `db:"observation_id" json:"observation_id"`
	ValidatorName string    `db:"validator_name" json:"validator_name"`
	Status        string    `db:"status" json:"status"` // PASS, FAIL, WARNING
	DurationMs    int       `db:"duration_ms" json:"duration_ms"`
	Warnings      []string  `db:"warnings" json:"warnings"`
	Errors        []string  `db:"errors" json:"errors"`
	CreatedAt     time.Time `db:"created_at" json:"created_at"`
}

type Provenance struct {
	SourceSessionID string `json:"source_session_id"`
	CandidateID     string `json:"candidate_id"`
}

type Observation struct {
	ID                  string  `db:"id" json:"id"`
	CandidateID         string  `db:"candidate_id" json:"candidate_id"`
	ParentObservationID *string `db:"parent_observation_id" json:"parent_observation_id"`
	PromptBundleID      string  `db:"prompt_bundle_id" json:"prompt_bundle_id"`
	ModelID             string  `db:"model_id" json:"model_id"`
	InferenceProfileID  string  `db:"inference_profile_id" json:"inference_profile_id"`

	InputFingerprint     string `db:"input_fingerprint" json:"input_fingerprint"`
	ExecutionFingerprint string `db:"execution_fingerprint" json:"execution_fingerprint"`

	Status             string  `db:"status" json:"status"` // GENERATED, VALIDATED, ACCEPTED, SUPERSEDED
	ObservationType    string  `db:"observation_type" json:"observation_type"`
	Confidence         float64 `db:"confidence" json:"confidence"`
	ObservationQuality float64 `db:"observation_quality" json:"observation_quality"`
	Summary            string  `db:"summary" json:"summary"`

	// Metrics from AIResponse
	AILatencyMs int64           `db:"ai_latency_ms" json:"ai_latency_ms"`
	AICost      float64         `db:"ai_cost" json:"ai_cost"`
	AIUsageJSON json.RawMessage `db:"ai_usage" json:"-"`
	AIRequestID string          `db:"ai_request_id" json:"ai_request_id"`

	ProvenanceJSON []byte     `db:"provenance" json:"-"`
	Provenance     Provenance `db:"-" json:"provenance"`
	CreatedAt      time.Time  `db:"created_at" json:"created_at"`
}

type Evidence struct {
	ID            string    `db:"id" json:"id"`
	ObservationID string    `db:"observation_id" json:"observation_id"`
	SkillID       string    `db:"skill_id" json:"skill_id"`
	Direction     string    `db:"direction" json:"direction"`
	Strength      float64   `db:"strength" json:"strength"`
	Reason        string    `db:"reason" json:"reason"`
	CreatedAt     time.Time `db:"created_at" json:"created_at"`
}

// AI Output Format Expected
type RawAIOutput struct {
	Confidence float64 `json:"confidence"`
	Summary    string  `json:"summary"`
	Skills     []struct {
		SkillID   string  `json:"skill_id"`
		Direction string  `json:"direction"`
		Strength  float64 `json:"strength"`
		Reason    string  `json:"reason"`
	} `json:"skills"`
}
