package token

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type TokenHandler struct {
	service *TokenService
}

func NewTokenHandler(service *TokenService) *TokenHandler {
	return &TokenHandler{service: service}
}

func (h *TokenHandler) GetStatus(c *gin.Context) {
	userIDStr, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	userID := userIDStr.(int64)
	status, err := h.service.GetStatus(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to get token status"})
		return
	}

	c.JSON(http.StatusOK, status)
}

func (h *TokenHandler) ConsumeOne(c *gin.Context) {
	userIDStr, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	userID := userIDStr.(int64)
	status, err := h.service.ConsumeOne(c.Request.Context(), userID)
	if err != nil {
		if err.Error() == "token limit reached" {
			if status == nil {
				c.JSON(http.StatusForbidden, gin.H{"error": "token limit reached", "remaining": 0})
			} else {
				c.JSON(http.StatusForbidden, gin.H{"error": "token limit reached", "remaining": status.Remaining})
			}
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to consume token"})
		return
	}

	c.JSON(http.StatusOK, status)
}
