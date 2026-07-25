package runtime

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/core/events"
)

type CurrentRuntimeResponse struct {
	SessionID      string         `json:"session_id"`
	ActivityID     string         `json:"activity_id"`
	Progress       int            `json:"progress"`
	Recommendation Recommendation `json:"recommendation"`
	Node           *PackNode      `json:"node"`
}

type Recommendation struct {
	Title            string `json:"title"`
	Subtitle         string `json:"subtitle"`
	EstimatedMinutes int    `json:"estimated_minutes"`
	ActionText       string `json:"action_text"`
	Reason           string `json:"reason"`
	Context          string `json:"context"`
}

type StartSessionRequest struct {
	LearningGoalID string `json:"learning_goal_id" binding:"required"`
	PackID         string `json:"pack_id" binding:"required"`
	PackVersion    string `json:"pack_version" binding:"required"`
}

type CurrentSessionResponse struct {
	Session        *RuntimeSession `json:"session"`
	Goal           interface{}     `json:"goal"` // Placeholder
	Node           *PackNode       `json:"node"`
	Pack           interface{}     `json:"pack"` // Placeholder
	Progress       int             `json:"progress"`
	Recommendation *Recommendation `json:"recommendation"`
}

type Handler struct {
	manager *Manager
	bus     *events.Bus
}

func NewHandler(manager *Manager, bus *events.Bus) *Handler {
	return &Handler{
		manager: manager,
		bus:     bus,
	}
}

// GetCurrent returns the user's current session and node context
func (h *Handler) GetCurrent(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	session, node, err := h.manager.GetCurrentSession(c.Request.Context(), userID)
	if err != nil {
		log.Printf("Error fetching session for %s: %v", userID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch session"})
		return
	}

	if session == nil {
		// Return empty 200 indicating no active session
		c.JSON(http.StatusOK, CurrentSessionResponse{})
		return
	}

	subtitle := ""
	if node != nil {
		subtitle = node.Title
	}

	// Dynamic Recommendation based on state
	rec := &Recommendation{
		Title:            "Current Session",
		Subtitle:         subtitle,
		EstimatedMinutes: 15,
		ActionText:       "Continue Activity",
		Reason:           "Based on your latest progress.",
		Context:          "Resume where you left off.",
	}

	resp := CurrentSessionResponse{
		Session:        session,
		Node:           node,
		Progress:       session.ProgressPercentage,
		Recommendation: rec,
	}

	c.JSON(http.StatusOK, resp)
}

// GetNode returns just the node data for the Workspace Shell
func (h *Handler) GetNode(c *gin.Context) {
	nodeID := c.Param("id")
	if nodeID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Node ID required"})
		return
	}

	node, err := h.manager.packRuntime.GetNode(c.Request.Context(), nodeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch node"})
		return
	}

	c.JSON(http.StatusOK, node)
}

// StartSession creates a new runtime session for the user
func (h *Handler) StartSession(c *gin.Context) {
	userID := c.GetString("user_id")
	log.Printf("🚀🚀🚀 StartSession called! UserID: %s", userID)
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req StartSessionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Wait! The user says "StartSession" should start the session based on the profile.
	// We don't even need PackID or LearningGoalID from the client anymore, because it comes from the Profile.
	// But let's just keep the old signature and we can pass the hardcoded "goal_ai_eng" and "pack_ai" from Flutter.
	startNodeID := "mission_sql_1"
	if req.LearningGoalID == "goal_python_auto" {
		startNodeID = "mission_python_1"
	}

	session, err := h.manager.InitializeSession(
		c.Request.Context(),
		userID,
		req.LearningGoalID,
		req.PackID,
		req.PackVersion,
		startNodeID,
	)

	if err != nil {
		log.Printf("StartSession error: %+v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to initialize session"})
		return
	}

	c.JSON(http.StatusOK, session)
}

type RuntimeEventRequest struct {
	SessionID string `json:"session_id" binding:"required"`
	Event     string `json:"event" binding:"required"` // MISSION_STARTED, CODE_EXECUTED, AI_ANALYZED, NODE_COMPLETED
	Data      string `json:"data"`
}

// HandleEvent processes events and updates the session progress/status
func (h *Handler) HandleEvent(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req RuntimeEventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	err := h.manager.HandleEvent(c.Request.Context(), req.SessionID, req.Event, req.Data)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to handle event"})
		return
	}

	h.bus.Emit(c.Request.Context(), userID, nil, events.EventType(req.Event), map[string]string{"data": req.Data, "session_id": req.SessionID})

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
