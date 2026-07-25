package journey

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/core/competency"
	"github.com/pradigi/backend/internal/core/curriculum"
	"github.com/pradigi/backend/internal/core/diagnosis"
)

// Handler serves HTTP endpoints for Academy Journeys.
type Handler struct {
	curriculumParser *curriculum.Parser
	orchestrator     *Orchestrator
	learningLoop     *LearningLoop
}

func NewHandler(baseDir string) *Handler {
	return &Handler{
		curriculumParser: curriculum.NewParser(baseDir),
		orchestrator:     NewOrchestrator(),
		learningLoop:     NewLearningLoop(diagnosis.NewEngine(), competency.NewEngine()),
	}
}

// GetAcademyJourney returns the curriculum structure and the user's current progress state.
// GET /api/v1/academies/:id/journeys/:curriculum_id
func (h *Handler) GetAcademyJourney(c *gin.Context) {
	academyID := c.Param("id")
	curriculumID := c.Param("curriculum_id")
	// userID := c.GetString("user_id") // Mocked for now

	// 1. Load Curriculum
	curr, err := h.curriculumParser.Parse(academyID, curriculumID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// 2. Fetch Journey State (Mocked creation for vertical slice)
	// In reality, we'd fetch from DB. If not exists, create it.
	firstNodeID := ""
	if len(curr.Units) > 0 && len(curr.Units[0].Lessons) > 0 && len(curr.Units[0].Lessons[0].Nodes) > 0 {
		firstNodeID = curr.Units[0].Lessons[0].Nodes[0].ID
	}

	journey, _ := h.orchestrator.StartJourney("user_1", curr.ID, firstNodeID)

	c.JSON(http.StatusOK, gin.H{
		"curriculum": curr,
		"journey":    journey,
	})
}

// CompleteNode is the CRITICAL ENDPOINT that closes the learning loop.
// When Flutter calls this after a mission/practice/reflection is done,
// the entire pipeline fires:
//
//	Evidence → Diagnosis → Competency Update → Delta Response
//
// POST /api/v1/journey/complete-node
func (h *Handler) CompleteNode(c *gin.Context) {
	var req struct {
		UserID        string `json:"user_id" binding:"required"`
		NodeID        string `json:"node_id" binding:"required"`
		MissionPassed bool   `json:"mission_passed"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	result, err := h.learningLoop.CompleteNode(req.UserID, req.NodeID, req.MissionPassed)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   result,
	})
}
