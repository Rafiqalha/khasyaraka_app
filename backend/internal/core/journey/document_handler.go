package journey

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/core/adaptive"
	"github.com/pradigi/backend/internal/core/competency"
	"github.com/pradigi/backend/internal/core/experience"
	"github.com/pradigi/backend/internal/core/learning_graph"
	"github.com/pradigi/backend/internal/core/session_context"
)

// DocumentBlock represents a single block in the adaptive notebook/document.
type DocumentBlock struct {
	Type     string            `json:"type"`               // markdown, code, adaptive, quiz
	ID       string            `json:"id,omitempty"`       // For adaptive and quiz blocks
	Content  string            `json:"content,omitempty"`  // For markdown
	Language string            `json:"language,omitempty"` // For code
	Fixture  string            `json:"fixture,omitempty"`  // For code
	Data     map[string]string `json:"data,omitempty"`     // Filled by Adaptive Planner
}

// GetAdaptiveExperience resolves a Node's document with the adaptation plan and XOE applied.
// GET /api/v1/academies/:id/journeys/:curriculum_id/nodes/:node_id/experience
func (h *Handler) GetAdaptiveExperience(c *gin.Context) {
	// academyID := c.Param("id")
	journeyID := c.Param("curriculum_id") // using this as journey ID for mock
	nodeID := c.Param("node_id")

	// 1. Build Session Context (Mocking raw inputs for now)
	ctxEngine := session_context.NewEngine()
	sessCtx := ctxEngine.BuildContext("user_1", "journey_1", map[string]interface{}{
		"focus_score":       70.0,
		"energy_score":      40.0, // Low energy -> Planner will choose "easy"
		"available_minutes": 15.0,
	})

	// 2. Fetch Competency Projection
	compEngine := competency.NewEngine()
	compProj, _ := compEngine.Project("user_1")

	// 3. Generate Adaptation Plan (Sets Goal)
	planner := adaptive.NewPlanner()
	plan := planner.GeneratePlan(sessCtx, compProj)

	// 4. Route Engine calculates DAG path to the goal
	// In reality, GoalConceptID should come from the planner's analysis of the current curriculum node
	routeEngine := learning_graph.NewRouteEngine()
	route := routeEngine.ComputeRoute(nodeID, compProj, sessCtx)

	// 5. Experience Orchestration Engine builds the UI DSL Manifest
	xoe := experience.NewOrchestrationEngine()
	manifest := xoe.Orchestrate(journeyID, route)

	c.JSON(http.StatusOK, gin.H{
		"context":  sessCtx,
		"plan":     plan,
		"route":    route,
		"manifest": manifest,
	})
}
