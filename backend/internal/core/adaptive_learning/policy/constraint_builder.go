package policy

import "github.com/pradigi/backend/internal/workbench/engine"

// ConstraintBuilder turns PolicyRecommendations into concrete Workbench Constraints.
type ConstraintBuilder struct{}

func NewConstraintBuilder() *ConstraintBuilder {
	return &ConstraintBuilder{}
}

// Build generates a list of Mission Constraints based on recommendations.
func (b *ConstraintBuilder) Build(recs []PolicyRecommendation) []engine.Constraint {
	var constraints []engine.Constraint

	for _, rec := range recs {
		switch rec.Type {
		case RecReduceAI:
			constraints = append(constraints, engine.Constraint{
				Type:     engine.ConstraintMaxHints,
				Value:    float64(1), // Max 1 hint
				Enforced: true,
			})
		case RecForceSystematic:
			constraints = append(constraints, engine.Constraint{
				Type:     engine.ConstraintMaxRuns,
				Value:    float64(5), // Limit rapid execution
				Enforced: true,
			})
		case RecEnforceTimeLimit:
			constraints = append(constraints, engine.Constraint{
				Type:     engine.ConstraintTimeLimit,
				Value:    float64(15), // 15 mins
				Enforced: true,
			})
		}
	}

	return constraints
}
