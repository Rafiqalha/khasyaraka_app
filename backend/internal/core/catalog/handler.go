package catalog

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

type JourneyService interface {
	InitializeJourney(ctx context.Context, userID, academyID, specializationID string) (map[string]string, error)
}

type Handler struct {
	svc     Service
	journey JourneyService
}

func NewHandler(svc Service, journey JourneyService) *Handler {
	return &Handler{svc: svc, journey: journey}
}

// CatalogResponse is the standard wrapper for all Catalog APIs
type CatalogResponse struct {
	CatalogVersion string      `json:"catalog_version"`
	GeneratedAt    time.Time   `json:"generated_at"`
	Items          interface{} `json:"items"`
}

func newCatalogResponse(items interface{}) CatalogResponse {
	return CatalogResponse{
		CatalogVersion: "2.1.0",
		GeneratedAt:    time.Now().UTC(),
		Items:          items,
	}
}

// GetAcademies returns the list of all academies.
func (h *Handler) GetAcademies(c *gin.Context) {
	academies, err := h.svc.GetAcademies(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch academies"})
		return
	}
	c.JSON(http.StatusOK, newCatalogResponse(academies))
}

// GetSpecializations returns specializations for an academy.
func (h *Handler) GetSpecializations(c *gin.Context) {
	academyID := c.Param("academy_id")
	if academyID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Academy ID is required"})
		return
	}

	specs, err := h.svc.GetSpecializations(c.Request.Context(), academyID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch specializations"})
		return
	}
	c.JSON(http.StatusOK, newCatalogResponse(specs))
}

// GetExperiences returns the list of experience levels.
func (h *Handler) GetExperiences(c *gin.Context) {
	experiences, err := h.svc.GetExperiences(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch experiences: " + err.Error()})
		return
	}
	c.JSON(http.StatusOK, newCatalogResponse(experiences))
}

// GetExecutionIntents returns the list of execution intents.
func (h *Handler) GetExecutionIntents(c *gin.Context) {
	intents, err := h.svc.GetExecutionIntents(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch intents: " + err.Error()})
		return
	}
	c.JSON(http.StatusOK, newCatalogResponse(intents))
}

// InitializeJourney creates an enrollment, a planner snapshot, and a runtime session.
func (h *Handler) InitializeJourney(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req struct {
		AcademyID        string `json:"academy_id"`
		SpecializationID string `json:"specialization_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Pass the initialization to the dedicated JourneyService which handles the full pipeline
	data, err := h.journey.InitializeJourney(c.Request.Context(), userID, req.AcademyID, req.SpecializationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to initialize journey: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   data,
	})
}
