package ai

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type AIHandler struct {
	service *AIService
}

func NewAIHandler(service *AIService) *AIHandler {
	return &AIHandler{service: service}
}

func (h *AIHandler) Chat(c *gin.Context) {
	userIDStr, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized", "error_code": "UNAUTHORIZED", "tokens_remaining": 0})
		return
	}
	userID := userIDStr.(int64)

	var req ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "error_code": "VALIDATION_ERROR", "tokens_remaining": 0})
		return
	}

	resp, err := h.service.Chat(c.Request.Context(), userID, req.Prompt)
	if err != nil {
		if err.Error() == "TOKEN_EXHAUSTED" {
			c.JSON(http.StatusForbidden, gin.H{"error": "Token habis", "error_code": "TOKEN_EXHAUSTED", "tokens_remaining": 0})
			return
		}
		if err.Error() == "AI_ERROR" {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "AI sedang gangguan, token kamu sudah dikembalikan", "error_code": "AI_ERROR", "tokens_remaining": 0})
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "error_code": "VALIDATION_ERROR", "tokens_remaining": 0})
		return
	}

	c.JSON(http.StatusOK, resp)
}
