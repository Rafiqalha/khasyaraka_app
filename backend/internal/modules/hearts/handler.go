package hearts

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/httputil"
)

// Handler holds hearts HTTP handlers.
type Handler struct {
	svc *Service
}

// NewHandler creates a new hearts handler.
func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

// GetHearts returns the current hearts count for a user.
func (h *Handler) GetHearts(c *gin.Context) {
	uid, err := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	if err != nil {
		httputil.Unauthorized(c, "invalid user id")
		return
	}

	hearts, err := h.svc.GetHearts(uid)
	if err != nil {
		httputil.InternalError(c, err.Error())
		return
	}

	httputil.Success(c, HeartsResponse{
		UserID:    uid,
		Hearts:    hearts,
		MaxHearts: maxHearts,
	}, "Hearts retrieved")
}

// Decrement decrements the hearts for the authenticated user.
func (h *Handler) Decrement(c *gin.Context) {
	uid, err := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	if err != nil {
		httputil.Unauthorized(c, "invalid user id")
		return
	}

	var req DecrementRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httputil.BadRequest(c, err.Error())
		return
	}

	newHearts, err := h.svc.DecrementHearts(uid, req.Amount)
	if err != nil {
		httputil.InternalError(c, err.Error())
		return
	}

	httputil.Success(c, HeartsResponse{
		UserID:    uid,
		Hearts:    newHearts,
		MaxHearts: maxHearts,
	}, "Hearts decremented")
}

// Increment increments the hearts for a user (used by AdMob callback).
func (h *Handler) Increment(c *gin.Context) {
	uid, err := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	if err != nil {
		httputil.Unauthorized(c, "invalid user id")
		return
	}

	var req IncrementRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httputil.BadRequest(c, err.Error())
		return
	}

	newHearts, err := h.svc.IncrementHearts(uid, req.Amount)
	if err != nil {
		httputil.InternalError(c, err.Error())
		return
	}

	httputil.Success(c, HeartsResponse{
		UserID:    uid,
		Hearts:    newHearts,
		MaxHearts: maxHearts,
	}, "Hearts incremented")
}

// DebugIncrement is a debug-only endpoint that increments hearts without auth.
// Simulates an AdMob rewarded video callback for testing.
func (h *Handler) DebugIncrement(c *gin.Context) {
	idStr := c.Param("id")
	uid, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		httputil.BadRequest(c, "invalid user id")
		return
	}

	newHearts, err := h.svc.IncrementHearts(uid, 1)
	if err != nil {
		httputil.InternalError(c, err.Error())
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    gin.H{"hearts": newHearts},
		"message": "Hearts simulated!",
	})
}
