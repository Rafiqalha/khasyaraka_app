package orchestrator

import (
	"github.com/gin-gonic/gin"
	pkghttp "github.com/pradigi/backend/internal/pkg/http"
)

type Handler struct {
	repo Repository
}

func NewHandler(repo Repository) *Handler {
	return &Handler{repo: repo}
}

func (h *Handler) GetDirective(c *gin.Context) {
	// Normally we get userID from Auth context
	userID := "user_123"

	directive, err := h.repo.GetLatestDirective(c.Request.Context(), userID)
	if err != nil {
		pkghttp.Internal(c, "Failed to get directive")
		return
	}

	pkghttp.Success(c, directive)
}
