// Package dataset defines the Dataset Builder — the passive downstream consumer.
// It only READS from existing data, never generates new facts.
// Its role is to produce anonymized research-grade datasets for:
// - AI model evaluation & benchmarking
// - Fine-tuning reasoning models
// - Education research & cognitive science
// - A/B testing learning strategies
package dataset

import (
	"context"
	"encoding/json"
)

// DatasetRecord is an anonymized, research-grade snapshot of a completed Mission.
type DatasetRecord struct {
	ExperimentID              string          `json:"experiment_id"`
	MissionSummaryID          string          `json:"mission_summary_id"`
	AnonymizedDecisionGraph   json.RawMessage `json:"anonymized_decision_graph"`
	AnonymizedCognitiveStates json.RawMessage `json:"anonymized_cognitive_states"`
	AnonymizedMetrics         json.RawMessage `json:"anonymized_metrics"`
	Tags                      []string        `json:"tags"`
}

// Builder is the interface for the Dataset Builder (the final downstream sink).
// It is purely a READ operation — it cannot mutate any upstream data.
type Builder interface {
	// BuildRecord creates an anonymized dataset entry from a sealed Mission Summary.
	BuildRecord(ctx context.Context, missionSummaryID string) (*DatasetRecord, error)

	// Flush persists the record to storage.
	Flush(ctx context.Context, record *DatasetRecord) error
}
