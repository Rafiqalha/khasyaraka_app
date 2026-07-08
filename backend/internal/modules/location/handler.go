package location

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/modules/auth"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) GetProvinsi(c *gin.Context) {
	provs := h.service.GetAllProvinsi()
	c.JSON(http.StatusOK, gin.H{"data": provs})
}

func (h *Handler) GetKabupaten(c *gin.Context) {
	provID := c.Query("provinsi_id")
	if provID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "provinsi_id is required"})
		return
	}
	kabs, err := h.service.GetKabupatenByProvinsi(provID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": kabs})
}

func (h *Handler) GetKecamatan(c *gin.Context) {
	kabID := c.Query("kabupaten_id")
	if kabID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "kabupaten_id is required"})
		return
	}
	kecs, err := h.service.GetKecamatanByKabupaten(kabID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": kecs})
}

func (h *Handler) SetLocation(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req SetLocationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	loc, err := h.service.SetUserLocation(c.Request.Context(), userID, req.KecamatanID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": loc, "message": "Location set successfully"})
}

func (h *Handler) GetMyLocation(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	loc, err := h.service.GetUserLocation(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": loc})
}
