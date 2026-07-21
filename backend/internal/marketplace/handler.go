package marketplace

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Handler manages the Marketplace Distribution API
type Handler struct {
	PackageManager *PackageManager
}

func NewHandler(pm *PackageManager) *Handler {
	return &Handler{PackageManager: pm}
}

// Search queries the configured registries for available packages.
// GET /api/v1/marketplace/search?q=cyber
func (h *Handler) Search(c *gin.Context) {
	// Mock search
	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": []RegistryEntry{
			{
				ID: "cyber_academy",
				Version: "1.0.0",
				PublisherID: "pradigi_official",
				MinimumOSVersion: "1.0.0",
			},
		},
	})
}

// GetPackageDetail returns the full metadata, versions, and dependencies for an academy.
// GET /api/v1/marketplace/packages/:id
func (h *Handler) GetPackageDetail(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": RegistryEntry{
			ID: c.Param("id"),
			PublisherID: "pradigi_official",
			Dependencies: []string{"foundation_os"},
		},
	})
}

// Install triggers the local Package Manager to download and verify a package.
// POST /api/v1/marketplace/packages/:id/install
func (h *Handler) Install(c *gin.Context) {
	id := c.Param("id")
	// In reality, resolve the download URL from the registry
	downloadURL := "https://registry.pradigi.id/download/" + id + "/v1.0.0.pack"
	
	if err := h.PackageManager.Install(downloadURL); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Package installed successfully"})
}

// ListInstalled returns all locally mounted Academy packages.
// GET /api/v1/marketplace/installed
func (h *Handler) ListInstalled(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": []string{"ai_academy", "cyber_academy"},
	})
}
