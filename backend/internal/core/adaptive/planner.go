package adaptive

import (
	"github.com/pradigi/backend/internal/core/competency"
	"github.com/pradigi/backend/internal/core/session_context"
)

// Planner generates an AdaptationPlan from a SessionContext.
type Planner struct{}

func NewPlanner() *Planner {
	return &Planner{}
}

// GeneratePlan maps the continuous/normalized context and competency projection into a discrete plan.
func (p *Planner) GeneratePlan(ctx *session_context.SessionContext, comp *competency.CompetencyProjection) *AdaptationPlan {
	plan := &AdaptationPlan{
		Difficulty:        "medium",
		NeedAnalogy:       false,
		NeedVisualization: false,
		MissionConstraint: "Standard",
		ReflectionDepth:   "low",
		EstimatedTimeMins: 20,
	}

	// Heuristics based on session context and competency projection
	if len(comp.WeakConcepts) > 0 {
		// User is struggling with concepts
		plan.Difficulty = "easy"
		plan.NeedAnalogy = true
		plan.NeedVisualization = true
		plan.ReflectionDepth = "high"
	} else if ctx.EnergyScore < 50 || ctx.AvailableMinutes < 20 {
		// Short, easy session
		plan.Difficulty = "easy"
		plan.NeedAnalogy = true
		plan.EstimatedTimeMins = 15
		plan.ReflectionDepth = "low"
	} else if ctx.FocusScore > 80 && ctx.EnergyScore > 80 {
		// Deep dive session
		plan.Difficulty = "hard"
		plan.NeedVisualization = true
		plan.EstimatedTimeMins = 45
		plan.ReflectionDepth = "high"
		plan.MissionConstraint = "AI Budget 1" // Restrict hints
	} else {
		// Standard
		plan.NeedAnalogy = true
	}

	return plan
}
