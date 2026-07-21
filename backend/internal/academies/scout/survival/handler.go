// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package survival

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

func (h *Handler) GetStatus(c *gin.Context) {
	uid, _ := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	status, err := h.svc.GetStatus(uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": status})
}

func (h *Handler) LogAction(c *gin.Context) {
	uid, _ := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	var req ActionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}
	if err := h.svc.LogAction(uid, req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Action logged"})
}

func (h *Handler) GetLeaderboard(c *gin.Context) {
	limit := 20
	entries, err := h.svc.GetLeaderboard(limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": entries})
}
