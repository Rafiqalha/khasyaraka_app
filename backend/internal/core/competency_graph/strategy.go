package competency_graph

import "context"

type PropagationContext struct {
	UserID            string
	RootSkillNodeID   string
	DeltaValue        float64
	OntologyVersionID string
}

type PropagationStrategy interface {
	Propagate(ctx context.Context, pCtx PropagationContext) ([]CompetencyContribution, error)
}

// Dummy strategy for MVP
type weightedStrategy struct {
	// Need ontology repo to fetch edges
}

func NewWeightedPropagationStrategy() PropagationStrategy {
	return &weightedStrategy{}
}

func (s *weightedStrategy) Propagate(ctx context.Context, pCtx PropagationContext) ([]CompetencyContribution, error) {
	// In reality, this traverses the DAG and calculates decaying deltas for parent nodes.
	// For MVP, just return the root delta.
	return []CompetencyContribution{
		{
			UserID:      pCtx.UserID,
			SkillNodeID: pCtx.RootSkillNodeID,
			Magnitude:   pCtx.DeltaValue,
		},
	}, nil
}
