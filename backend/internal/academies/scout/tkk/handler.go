// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package tkk

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) ListBadges(c *gin.Context) {
	uid, _ := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	badges, err := h.svc.GetBadges(uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": badges})
}

func (h *Handler) Attain(c *gin.Context) {
	uid, _ := strconv.ParseInt(c.GetString("user_id"), 10, 64)

	var req AttainRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	badge, err := h.svc.Attain(uid, req.TkkSlug, req.Level)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": badge, "message": "TKK badge attained"})
}
