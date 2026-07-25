package career

import (
	"context"
)

type GapAnalysisResult struct {
	ReadinessScore float64
	GapDetails     map[string]float64 // NodeID -> gap distance
}

type GapAnalyzer interface {
	AnalyzeGap(ctx context.Context, userID string, targetRoleID string) (*GapAnalysisResult, error)
}

type analyzer struct{}

func NewGapAnalyzer() GapAnalyzer {
	return &analyzer{}
}

func (a *analyzer) AnalyzeGap(ctx context.Context, userID string, targetRoleID string) (*GapAnalysisResult, error) {
	// For MVP, simulate a gap analysis based on Competency Projection vs Role Ontology.
	// In reality:
	// 1. Fetch Target Role requirements from Ontology.
	// 2. Fetch User's current Competency Projection.
	// 3. Compute delta (Gap = TargetLevel - CurrentScore).

	result := &GapAnalysisResult{
		ReadinessScore: 78.5,
		GapDetails: map[string]float64{
			"skill_api_design":  21.5,
			"skill_concurrency": 10.0,
		},
	}

	return result, nil
}
