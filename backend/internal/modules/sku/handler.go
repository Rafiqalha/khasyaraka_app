package sku

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

func userID(c *gin.Context) *int64 {
	s := c.GetString("user_id")
	if s == "" {
		return nil
	}
	id, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return nil
	}
	return &id
}

func (h *Handler) ListPoints(c *gin.Context) {
	points, err := h.svc.GetPoints(userID(c))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": points})
}

func (h *Handler) GetPoint(c *gin.Context) {
	id := c.Param("id")
	point, err := h.svc.GetPoint(id, userID(c))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": point})
}

func (h *Handler) SubmitQuiz(c *gin.Context) {
	uid, ok := func() (int64, bool) {
		s := c.GetString("user_id")
		if s == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "authentication required", "success": false})
			return 0, false
		}
		id, err := strconv.ParseInt(s, 10, 64)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid user id", "success": false})
			return 0, false
		}
		return id, true
	}()
	if !ok {
		return
	}

	var req SubmitQuizRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	score, err := h.svc.SubmitQuiz(uid, c.Param("id"), req.Answers)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"score": score}, "message": "Quiz submitted"})
}
