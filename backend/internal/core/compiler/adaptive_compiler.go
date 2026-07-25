package compiler

import (
	"context"

	"github.com/pradigi/backend/internal/core/catalog"
	"github.com/pradigi/backend/internal/core/llm"
	"github.com/pradigi/backend/internal/core/telemetry"
)

// AdaptiveCurriculumCompiler - Provider-agnostic adaptive compiler orchestrating
// RevisionBank, TelemetryAnalyzer, and LLM Provider Backends (DeepSeek/Gemini/Local).
type AdaptiveCurriculumCompiler struct {
	bank     *RevisionBank
	analyzer *telemetry.TelemetryAnalyzer
	llm      llm.Client
}

func NewAdaptiveCurriculumCompiler(bank *RevisionBank, analyzer *telemetry.TelemetryAnalyzer, llmClient llm.Client) *AdaptiveCurriculumCompiler {
	if bank == nil {
		bank = NewRevisionBank()
	}
	if analyzer == nil {
		analyzer = telemetry.NewTelemetryAnalyzer()
	}
	return &AdaptiveCurriculumCompiler{
		bank:     bank,
		analyzer: analyzer,
		llm:      llmClient,
	}
}

// CompileAdaptiveRevision resolves an adaptive MissionRevision from RevisionBank or LLM
func (c *AdaptiveCurriculumCompiler) CompileAdaptiveRevision(
	ctx context.Context,
	conceptID string,
	telemetryIn telemetry.TelemetryInput,
	retryCount int,
) (*MissionRevision, error) {

	// 1. Analyze Telemetry -> LearningDiagnosis JSON
	diag := c.analyzer.Analyze(telemetryIn)

	// 2. Try instant RevisionBank cache match (<1ms)
	if rev, ok := c.bank.SelectRevision(conceptID, diag, retryCount); ok {
		return rev, nil
	}

	// 3. Fallback: If RevisionBank cache misses, construct new Revision
	fallbackRev := &MissionRevision{
		ID:           conceptID + "_remediated",
		ConceptID:    conceptID,
		RevisionNum:  retryCount + 1,
		Pedagogy:     diag.Recommendation,
		Difficulty:   diag.Difficulty,
		Title:        "Remediated Mission: " + conceptID,
		Objective:    "Targeted exercise based on diagnostic recommendation: " + diag.Recommendation,
		Instructions: "Follow the guided instructions to resolve your struggle with " + diag.Problem + ".",
		TemplateCode: "# Remediated Template for " + conceptID + "\n",
	}

	c.bank.AddRevision(conceptID, fallbackRev)
	return fallbackRev, nil
}

// CompileNextConceptNode resolves the next concept node when user passes
func (c *AdaptiveCurriculumCompiler) CompileNextConceptNode(
	ctx context.Context,
	pack *catalog.PackBlueprint,
	completedConceptID string,
) (*catalog.MissionBlueprint, error) {
	if pack == nil || len(pack.Missions) == 0 {
		return nil, nil
	}

	// Find next mission node in pack
	for i, m := range pack.Missions {
		for _, k := range m.CompetencyKeys {
			if k == completedConceptID && i+1 < len(pack.Missions) {
				return pack.Missions[i+1], nil
			}
		}
	}

	return pack.Missions[0], nil
}
