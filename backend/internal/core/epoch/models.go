package epoch

import "time"

type KnowledgeEpoch struct {
	ID                  string    `db:"id" json:"id"`
	Name                string    `db:"name" json:"name"`
	Version             string    `db:"version" json:"version"`
	Fingerprint         string    `db:"fingerprint" json:"fingerprint"`
	OntologyVersionID   string    `db:"ontology_version_id" json:"ontology_version_id"`
	GovernanceBundleID  string    `db:"governance_bundle_id" json:"governance_bundle_id"`
	ProjectionFormulaID string    `db:"projection_formula_id" json:"projection_formula_id"`
	PromptBundleID      *string   `db:"prompt_bundle_id" json:"prompt_bundle_id"`
	ModelRegistryID     *string   `db:"model_registry_id" json:"model_registry_id"`
	CreatedAt           time.Time `db:"created_at" json:"created_at"`
}

type EpochCompatibility struct {
	ID                      string    `db:"id" json:"id"`
	EpochID                 string    `db:"epoch_id" json:"epoch_id"`
	CompatibleEntityType    string    `db:"compatible_entity_type" json:"compatible_entity_type"`
	CompatibleEntityVersion string    `db:"compatible_entity_version" json:"compatible_entity_version"`
	CreatedAt               time.Time `db:"created_at" json:"created_at"`
}

type ReplayCertification struct {
	ID                 string    `db:"id" json:"id"`
	EpochID            string    `db:"epoch_id" json:"epoch_id"`
	SuccessRate        float64   `db:"success_rate" json:"success_rate"`
	DeterminismScore   float64   `db:"determinism_score" json:"determinism_score"`
	DurationMs         int       `db:"duration_ms" json:"duration_ms"`
	ProjectionAccuracy float64   `db:"projection_accuracy" json:"projection_accuracy"`
	FingerprintMatch   bool      `db:"fingerprint_match" json:"fingerprint_match"`
	EpochMatch         bool      `db:"epoch_match" json:"epoch_match"`
	Status             string    `db:"status" json:"status"` // CERTIFIED, FAILED
	CreatedAt          time.Time `db:"created_at" json:"created_at"`
}
