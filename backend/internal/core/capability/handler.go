package capability

import (
	"github.com/gin-gonic/gin"
	httputil "github.com/pradigi/backend/internal/pkg/http"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) GetMe(c *gin.Context) {
	userID := c.GetString("user_id")

	res, err := h.svc.GetMyCapabilities(userID)
	if err != nil {
		httputil.Internal(c, "Failed to get capabilities")
		return
	}

	httputil.Success(c, res)
}
