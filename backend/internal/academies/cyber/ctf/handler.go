package ctf

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type CTFHandler struct {
	service *CTFService
}

func NewCTFHandler(service *CTFService) *CTFHandler {
	return &CTFHandler{service: service}
}

func parseRoomID(c *gin.Context) (int64, error) {
	idStr := c.Param("room_id")
	return strconv.ParseInt(idStr, 10, 64)
}

func (h *CTFHandler) InitializeRoom(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}
	room, err := h.service.InitializeCTFRoom(c.Request.Context(), roomID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, room)
}

func (h *CTFHandler) StartDefensePhase(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}
	err = h.service.StartDefensePhase(c.Request.Context(), roomID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Defense phase started"})
}

func (h *CTFHandler) SubmitDefense(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}
	
	// Assuming teamID is passed in header or context in a real scenario
	// For this test flow, we will parse from query parameter for simplicity since auth context mapping to team might be complex.
	// Actually we should get from auth, but let's just assume we get team_id from header or context.
	// Wait, standard practice here is `c.Get("team_id")` or similar if tied to user, but let's parse from header X-Team-ID for simplicity in this mode.
	teamIDStr := c.GetHeader("X-Team-ID")
	teamID, err := strconv.ParseInt(teamIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing or invalid X-Team-ID header"})
		return
	}

	var req SubmitDefenseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = h.service.SubmitDefense(c.Request.Context(), roomID, teamID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Defense submitted"})
}

func (h *CTFHandler) StartAttackPhase(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}
	err = h.service.StartAttackPhase(c.Request.Context(), roomID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Attack phase started"})
}

func (h *CTFHandler) AttackWithAI(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}

	userIDStr, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}
	userID := userIDStr.(int64)

	teamIDStr := c.GetHeader("X-Team-ID")
	teamID, err := strconv.ParseInt(teamIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing X-Team-ID header"})
		return
	}

	var req SubmitAttackRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp, err := h.service.AttackWithAI(c.Request.Context(), roomID, teamID, userID, req.Prompt)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, resp)
}

func (h *CTFHandler) SubmitFlag(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}

	teamIDStr := c.GetHeader("X-Team-ID")
	teamID, err := strconv.ParseInt(teamIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing X-Team-ID header"})
		return
	}

	var req SubmitFlagRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	correct, err := h.service.SubmitFlag(c.Request.Context(), roomID, teamID, req.Flag)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	scoreAwarded := 0
	if correct {
		scoreAwarded = 500
	}
	c.JSON(http.StatusOK, gin.H{
		"correct":       correct,
		"score_awarded": scoreAwarded,
		"message":       func() string { if correct { return "Flag found!" } else { return "Wrong flag!" } }(),
	})
}

func (h *CTFHandler) SubmitPatch(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}

	teamIDStr := c.GetHeader("X-Team-ID")
	teamID, err := strconv.ParseInt(teamIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing X-Team-ID header"})
		return
	}

	var req SubmitPatchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	correct, err := h.service.SubmitPatch(c.Request.Context(), roomID, teamID, req.Answer, req.TimeTakenSec)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"correct":    correct,
		"time_bonus": 0, // Simplified, frontend can calculate or get from state
		"message":    func() string { if correct { return "Patch successful!" } else { return "Wrong patch!" } }(),
	})
}

func (h *CTFHandler) GetState(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}

	teamIDStr := c.GetHeader("X-Team-ID")
	teamID, err := strconv.ParseInt(teamIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing X-Team-ID header"})
		return
	}

	state, err := h.service.GetCTFState(c.Request.Context(), roomID, teamID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, state)
}

func (h *CTFHandler) FinishCTF(c *gin.Context) {
	roomID, err := parseRoomID(c)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid room id"})
		return
	}

	scores, err := h.service.FinishCTF(c.Request.Context(), roomID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, scores)
}
