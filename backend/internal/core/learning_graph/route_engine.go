package learning_graph

import (
	"github.com/pradigi/backend/internal/core/competency"
	"github.com/pradigi/backend/internal/core/session_context"
)

// RouteEngine computes the optimal path to reach a specific learning goal.
// While Adaptive Planner sets the goal, RouteEngine plots the exact turn-by-turn path.
type RouteEngine struct {}

func NewRouteEngine() *RouteEngine {
	return &RouteEngine{}
}

// ComputeRoute analyzes the target concept, the user's competency, and session context,
// and determines the optimal sequence of LearningAssets to serve.
func (re *RouteEngine) ComputeRoute(goalConceptID string, compProj *competency.CompetencyProjection, sessCtx *session_context.SessionContext) *RouteRecommendation {
	// Look up the goal concept in the projection
	state, exists := compProj.Concepts[goalConceptID]
	
	route := &RouteRecommendation{
		GoalConceptID: goalConceptID,
	}

	// Simple heuristic based on Probabilistic Distribution
	// If confidence is low or mean is low, the route must include foundational assets first.
	if !exists || state.Knowledge.Mean < 60 || state.Knowledge.ConfidenceInterval > 15 {
		// Route: Notebook -> Visualization -> Practice -> Mission
		route.RecommendedAssets = []string{
			"asset_" + goalConceptID + "_notebook",
			"asset_" + goalConceptID + "_viz",
			"asset_" + goalConceptID + "_practice",
			"asset_" + goalConceptID + "_mission",
		}
		route.EstimatedSuccess = 0.55 // low chance of first-try success for missions, hence the prep
	} else {
		// Route: Mission (User is strong, jump straight into action)
		route.RecommendedAssets = []string{
			"asset_" + goalConceptID + "_mission",
		}
		route.EstimatedSuccess = 0.82 // 82% chance based on strong previous evidence
	}

	return route
}
