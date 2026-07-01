package cyber

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

func userIDPtr(c *gin.Context) *int64 {
	idStr := c.GetString("user_id")
	if idStr == "" {
		return nil
	}
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		return nil
	}
	return &id
}

func requireID(c *gin.Context) (int64, bool) {
	idStr := c.GetString("user_id")
	if idStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "authentication required", "success": false})
		return 0, false
	}
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid user id", "success": false})
		return 0, false
	}
	return id, true
}

func (h *Handler) ListModules(c *gin.Context) {
	uid := userIDPtr(c)
	modules, err := h.svc.GetModules(uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": modules})
}

func (h *Handler) GetModule(c *gin.Context) {
	id := c.Param("id")
	uid := userIDPtr(c)

	module, err := h.svc.GetModuleDetail(id, uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": module})
}

func (h *Handler) GetChallenge(c *gin.Context) {
	id := c.Param("id")
	uid, ok := requireID(c)
	if !ok {
		return
	}

	challenge, err := h.svc.GetChallenge(id, uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": challenge})
}

func (h *Handler) SolveChallenge(c *gin.Context) {
	id := c.Param("id")
	uid, ok := requireID(c)
	if !ok {
		return
	}

	var req SolveRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	correct, xp, err := h.svc.SolveChallenge(uid, id, req.Answer)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	if !correct {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"correct": false}, "message": "Wrong answer"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    gin.H{"correct": true, "xp_earned": xp},
		"message": "Challenge solved!",
	})
}
