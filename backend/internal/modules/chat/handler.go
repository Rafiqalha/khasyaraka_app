package chat

import (
	"errors"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/modules/auth"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func (h *Handler) GetUserRooms(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	rooms, err := h.service.GetUserRooms(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": rooms})
}

func (h *Handler) GetMessages(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	roomID, err := strconv.ParseInt(c.Param("room_id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room_id"})
		return
	}

	beforeID, _ := strconv.ParseInt(c.Query("before_id"), 10, 64)
	limit, _ := strconv.Atoi(c.Query("limit"))
	if limit == 0 {
		limit = 50
	}

	msgs, hasMore, err := h.service.GetMessages(c.Request.Context(), userID, roomID, beforeID, limit)
	if err != nil {
		fmt.Println("GetMessages Error:", err)
		if errors.Is(err, ErrNotRoomMember) {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": GetMessagesResponse{
		Messages: msgs,
		HasMore:  hasMore,
	}})
}

func (h *Handler) SendMessage(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	roomID, err := strconv.ParseInt(c.Param("room_id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room_id"})
		return
	}

	var req SendMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	msg, err := h.service.SendMessage(c.Request.Context(), userID, roomID, req)
	if err != nil {
		fmt.Println("SendMessage Error:", err)
		if errors.Is(err, ErrNotRoomMember) {
			c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": msg})
}

func (h *Handler) GetRoomInfo(c *gin.Context) {
	roomID, err := strconv.ParseInt(c.Param("room_id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room_id"})
		return
	}

	info, err := h.service.GetRoomInfo(c.Request.Context(), roomID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": info})
}

func (h *Handler) ServeWS(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	h.service.ServeWS(c, userID)
}
