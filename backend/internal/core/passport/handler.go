package passport

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Handler manages the Skill Passport API endpoints
type Handler struct{}

func NewHandler() *Handler {
	return &Handler{}
}

// GetPublicPassport returns a user's skill passport, filtered by their VisibilitySettings.
// GET /api/v1/passports/:user_id
func (h *Handler) GetPublicPassport(c *gin.Context) {
	// userID := c.Param("user_id")

	// 1. Fetch user's settings (Mocked)
	settings := VisibilitySettings{
		ShowCredentials:  true,
		ShowCompetencies: true,
		ShowEvidence:     false,
		ShowReflection:   false,
		ShowProjects:     true,
	}

	// 2. Fetch data (Mocked)
	passport := SkillPassport{
		UserID:     "user_rafiq",
		Visibility: settings,
	}

	// 3. Apply privacy filters before returning
	if !settings.ShowEvidence {
		// Nil out evidence in the graph/snapshot
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": passport})
}

// GetEvidenceExplorer returns the drill-down execution trace for a specific credential claim.
// GET /api/v1/passports/:user_id/evidence/:concept_id
func (h *Handler) GetEvidenceExplorer(c *gin.Context) {
	// 1. Validate if user's privacy settings allow showing evidence
	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   "Mock Evidence Trace: Execution Logs for Bug Fix 01",
	})
}
