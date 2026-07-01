package training

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

func userIDFromCtx(c *gin.Context) *int64 {
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

func requireUserID(c *gin.Context) (int64, bool) {
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

func (h *Handler) ListSections(c *gin.Context) {
	sections, err := h.svc.GetSections()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": sections})
}

func (h *Handler) GetSection(c *gin.Context) {
	id := c.Param("id")
	uid := userIDFromCtx(c)

	sec, err := h.svc.GetSectionDetail(id, uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": sec})
}

func (h *Handler) GetUnit(c *gin.Context) {
	id := c.Param("id")
	uid := userIDFromCtx(c)

	unit, err := h.svc.GetUnitDetail(id, uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": unit})
}

func (h *Handler) GetLevel(c *gin.Context) {
	id := c.Param("id")
	uid, ok := requireUserID(c)
	if !ok {
		return
	}

	level, questions, err := h.svc.GetLevelQuestions(id, uid)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{
		"level":     level,
		"questions": questions,
	}})
}

func (h *Handler) SubmitLevel(c *gin.Context) {
	id := c.Param("id")
	uid, ok := requireUserID(c)
	if !ok {
		return
	}

	var req SubmitRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	result, err := h.svc.SubmitLevel(uid, id, req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    result,
		"message": "Level submitted",
	})
}

func (h *Handler) GetProgress(c *gin.Context) {
	uid, ok := requireUserID(c)
	if !ok {
		return
	}

	summary, err := h.svc.GetProgress(uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": summary})
}
