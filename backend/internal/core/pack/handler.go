package pack

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	registry Registry
	loader   Loader
}

func NewHandler(registry Registry, loader Loader) *Handler {
	return &Handler{
		registry: registry,
		loader:   loader,
	}
}

// ListPacks handles GET /api/v2/packs
func (h *Handler) ListPacks(c *gin.Context) {
	descriptors, err := h.registry.Installed()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list packs: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   descriptors,
	})
}

// GetPack handles GET /api/v2/packs/:id
func (h *Handler) GetPack(c *gin.Context) {
	packID := c.Param("id")
	desc, err := h.registry.Get(packID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pack not found"})
		return
	}

	p, err := h.loader.Load(c.Request.Context(), desc)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load pack details: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			"descriptor":   p.Descriptor,
			"title":        p.Title,
			"description":  p.Description,
			"capabilities": p.Capabilities,
			"workspace":    p.Workspace,
			"assessment":   p.Assessment,
			"knowledge":    p.Knowledge,
			"missions":     p.Missions,
			"ai_rules":     p.AIRules,
		},
	})
}

// ListMissions handles GET /api/v2/packs/:id/missions
func (h *Handler) ListMissions(c *gin.Context) {
	packID := c.Param("id")
	desc, err := h.registry.Get(packID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pack not found"})
		return
	}

	p, err := h.loader.Load(c.Request.Context(), desc)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load pack missions: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   p.Missions,
	})
}

// RegisterRoutes registers pack API routes under /api/v2/packs
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	rg.GET("", h.ListPacks)
	rg.GET("/:id", h.GetPack)
	rg.GET("/:id/missions", h.ListMissions)
}
