package identity

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

	res, err := h.svc.GetFullProfile(userID)
	if err != nil {
		httputil.Internal(c, "Failed to get profile")
		return
	}

	httputil.Success(c, res)
}

func (h *Handler) UpdateMe(c *gin.Context) {
	userID := c.GetString("user_id")

	var req UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httputil.BadRequest(c, httputil.CodeInvalidRequest, "Invalid request payload")
		return
	}

	profile, err := h.svc.UpdateProfile(userID, &req)
	if err != nil {
		httputil.BadRequest(c, httputil.CodeInvalidRequest, err.Error())
		return
	}

	httputil.Success(c, profile)
}

func (h *Handler) Onboard(c *gin.Context) {
	userID := c.GetString("user_id")

	var req OnboardingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httputil.BadRequest(c, httputil.CodeInvalidRequest, "Invalid request payload")
		return
	}

	if err := h.svc.Onboard(userID, &req); err != nil {
		httputil.BadRequest(c, httputil.CodeInvalidRequest, err.Error())
		return
	}

	httputil.Success(c, nil)
}
