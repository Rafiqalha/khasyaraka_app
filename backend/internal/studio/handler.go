package studio

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Handler manages Academy Studio API endpoints
type Handler struct{}

func NewHandler() *Handler {
	return &Handler{}
}

// HandleUpdateBlock mutates the physical YAML/Markdown on disk (Git is the SoT).
// POST /api/v1/studio/commands/update-block
func (h *Handler) HandleUpdateBlock(c *gin.Context) {
	var cmd UpdateBlockCommand
	if err := c.ShouldBindJSON(&cmd); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 1. Locate Academy asset file
	// 2. Parse Markdown AST
	// 3. Mutate Block
	// 4. Save file to disk
	// (Implementation mocked for Sprint A8)

	c.JSON(http.StatusOK, gin.H{"status": "success", "command": cmd})
}

// HandlePreviewAdaptive simulates the Adaptive Engine without mutating user state.
// POST /api/v1/studio/commands/preview-adaptive
func (h *Handler) HandlePreviewAdaptive(c *gin.Context) {
	var cmd PreviewAdaptiveExperienceCommand
	if err := c.ShouldBindJSON(&cmd); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 1. Construct Mock Competency Projection based on Persona
	// 2. Run Route Engine
	// 3. Run Experience Orchestration Engine (XOE)
	// (Implementation mocked for Sprint A8)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"manifest": map[string]interface{}{
			"type":    "mock_adaptive_manifest",
			"persona": cmd.PersonaType,
		},
	})
}
