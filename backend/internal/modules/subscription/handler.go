package subscription

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

func (h *Handler) GetStatus(c *gin.Context) {
	uid, _ := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	sub, err := h.svc.GetStatus(uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	if sub == nil {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"tier": "free"}})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": sub})
}

func (h *Handler) Create(c *gin.Context) {
	uid, _ := strconv.ParseInt(c.GetString("user_id"), 10, 64)

	var req CreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	sub, err := h.svc.Create(uid, req.Tier, req.PaymentReference, req.BillingProvider)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": sub, "message": "Subscription created"})
}

func (h *Handler) Cancel(c *gin.Context) {
	uid, _ := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	if err := h.svc.Cancel(uid); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Subscription cancelled"})
}
