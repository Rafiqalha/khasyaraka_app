package leaderboard

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func normalizeScope(scope string) string {
	switch strings.ToLower(scope) {
	case "district", "kecamatan":
		return "kecamatan"
	case "city", "kota":
		return "kota"
	case "province", "provinsi":
		return "provinsi"
	case "country", "negara":
		return "country"
	default:
		return "global"
	}
}

func (h *Handler) GetTop(c *gin.Context) {
	limit := 20
	if l := c.Query("limit"); l != "" {
		if n, err := strconv.Atoi(l); err == nil && n > 0 {
			limit = n
		}
	}
	category := c.Query("category")
	scope := normalizeScope(c.Query("scope"))
	locationID := c.Query("value")
	if locationID == "" {
		locationID = c.Query("location_id")
	}

	entries, err := h.svc.GetTop(category, scope, locationID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": entries})
}

func (h *Handler) GetRank(c *gin.Context) {
	uid, _ := strconv.ParseInt(c.GetString("user_id"), 10, 64)
	category := c.Query("category")
	scope := normalizeScope(c.Query("scope"))
	locationID := c.Query("value")
	if locationID == "" {
		locationID = c.Query("location_id")
	}

	rank, err := h.svc.GetUserRank(uid, category, scope, locationID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	if rank == nil {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"rank": nil, "total_xp": 0}})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": rank})
}
