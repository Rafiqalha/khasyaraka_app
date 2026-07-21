package engine

import (
	"context"
	"encoding/json"

	"github.com/pradigi/backend/internal/workbench/domain"
)

// ===========================
// Experiment Analyzer
// Sits BETWEEN Mission Summary and Observation Candidate.
// Reasoning OS receives Experiment-level context, not raw Mission-level data.
//
// One Experiment can contain 3 Missions → 1 Experiment Summary.
// ===========================

type ExperimentSummary struct {
	ExperimentID      string                    `json:"experiment_id"`
	MissionCount      int                       `json:"mission_count"`
	CompletedMissions int                       `json:"completed_missions"`
	AbandonedMissions int                       `json:"abandoned_missions"`
	TotalCompiles     int                       `json:"total_compiles"`
	TotalRuns         int                       `json:"total_runs"`
	TotalAICalls      int                       `json:"total_ai_calls"`
	TotalDurationSec  int                       `json:"total_duration_sec"`
	DominantCogState  domain.CognitiveStateValue `json:"dominant_cognitive_state"`
	Observations      []string                  `json:"observations"` // High-level deterministic findings
}

type ExperimentAnalyzer struct{}

func NewExperimentAnalyzer() *ExperimentAnalyzer {
	return &ExperimentAnalyzer{}
}

// Analyze aggregates multiple Mission Summaries into a single Experiment Summary.
// This is deterministic — no LLM.
func (a *ExperimentAnalyzer) Analyze(
	ctx context.Context,
	experimentID string,
	summaries []domain.MissionSummary,
) *ExperimentSummary {
	result := &ExperimentSummary{
		ExperimentID: experimentID,
		MissionCount: len(summaries),
	}

	stateFreq := make(map[domain.CognitiveStateValue]int)

	for _, s := range summaries {
		result.TotalCompiles += s.CompileCount
		result.TotalRuns += s.RunCount
		result.TotalAICalls += s.AICalls
		result.TotalDurationSec += s.DurationSeconds

		switch s.Outcome {
		case "Solved", "Solved with AI":
			result.CompletedMissions++
		case "Abandoned", "Timed Out":
			result.AbandonedMissions++
		}

		if s.FinalCognitiveState != nil {
			stateFreq[*s.FinalCognitiveState]++
		}
	}

	// Find dominant cognitive state
	maxFreq := 0
	for state, freq := range stateFreq {
		if freq > maxFreq {
			maxFreq = freq
			result.DominantCogState = state
		}
	}

	// Generate deterministic observations
	if result.TotalAICalls > result.TotalRuns {
		result.Observations = append(result.Observations, "High AI dependency: more AI calls than code runs.")
	}
	if result.AbandonedMissions > result.CompletedMissions {
		result.Observations = append(result.Observations, "Low persistence: more missions abandoned than completed.")
	}
	if result.TotalCompiles > 0 && result.CompletedMissions == result.MissionCount {
		result.Observations = append(result.Observations, "Excellent completion: all missions solved.")
	}
	if result.DominantCogState == domain.CognitiveStateBlocked {
		result.Observations = append(result.Observations, "Frequently blocked: user may need scaffolding.")
	}

	return result
}

// ToObservationPayload converts the summary to a JSON payload for Observation Candidate.
func (s *ExperimentSummary) ToObservationPayload() json.RawMessage {
	data, _ := json.Marshal(s)
	return data
}
