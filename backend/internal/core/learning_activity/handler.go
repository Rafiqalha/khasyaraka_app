package learning_activity

import (
	"net/http"

	"github.com/gin-gonic/gin"
	apphttp "github.com/pradigi/backend/internal/pkg/http"
)

type Handler struct {
	service Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{service: svc}
}

func (h *Handler) RecordActivity(c *gin.Context) {
	var req RecordActivityCommand
	if err := c.ShouldBindJSON(&req); err != nil {
		apphttp.BadRequest(c, apphttp.CodeInvalidRequest, "Invalid request body")
		return
	}

	req.UserID = c.GetString("user_id")

	err := h.service.RecordActivity(c.Request.Context(), req)
	if err != nil {
		apphttp.Internal(c, err.Error())
		return
	}

	c.JSON(http.StatusAccepted, gin.H{"status": "learning_activity_recorded"})
}
