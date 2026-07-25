// Package session — Workbench API Handler.
// Exposes the Cognitive Workbench to the outside world via REST endpoints.
// All requests flow through Session Orchestrator as Commands.
package session

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/workbench/agent"
	"github.com/pradigi/backend/internal/workbench/domain"
	"github.com/pradigi/backend/internal/workbench/engine"
	"github.com/pradigi/backend/internal/workbench/runtime"
)

type Handler struct {
	runtimeRegistry *runtime.Registry
	policy          runtime.ExecutionPolicy
	evaluator       engine.Evaluator
	objectiveEngine *engine.ObjectiveEngine
	agentFactory    agent.AgentFactory
	roleRegistry    *agent.RoleRegistry
	// Active sessions (in production: backed by DB)
	sessions map[string]*Orchestrator
}

func NewHandler(
	registry *runtime.Registry,
	policy runtime.ExecutionPolicy,
	evaluator engine.Evaluator,
	objectiveEngine *engine.ObjectiveEngine,
	agentFactory agent.AgentFactory,
	roleRegistry *agent.RoleRegistry,
) *Handler {
	return &Handler{
		runtimeRegistry: registry,
		policy:          policy,
		evaluator:       evaluator,
		objectiveEngine: objectiveEngine,
		agentFactory:    agentFactory,
		roleRegistry:    roleRegistry,
		sessions:        make(map[string]*Orchestrator),
	}
}

// StartSession creates a new Mission Session and returns its ID.
// POST /api/v1/workbench/sessions
func (h *Handler) StartSession(c *gin.Context) {
	var req struct {
		UserID       string `json:"user_id" binding:"required"`
		ExperimentID string `json:"experiment_id" binding:"required"`
		MissionID    string `json:"mission_id" binding:"required"`
		ScenarioID   string `json:"scenario_id" binding:"required"`
		Objective    string `json:"objective" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	session := &MissionSession{
		ID:                    ulid.Make().String(),
		UserID:                req.UserID,
		ExperimentID:          req.ExperimentID,
		MissionID:             req.MissionID,
		ScenarioID:            req.ScenarioID,
		Status:                SessionStatusActive,
		CurrentObjective:      req.Objective,
		CurrentCognitiveState: domain.CognitiveStateExploring,
		StartedAt:             time.Now(),
	}

	orch := NewOrchestrator(
		session,
		h.runtimeRegistry,
		h.policy,
		h.evaluator,
		h.objectiveEngine,
		h.agentFactory,
		h.roleRegistry,
	)
	h.sessions[session.ID] = orch

	// Emit MissionStarted
	startPayload, _ := json.Marshal(map[string]string{
		"mission_id": req.MissionID,
		"objective":  req.Objective,
	})
	orch.emitEvent(domain.WBEventMissionStarted, "SYSTEM", "session_orchestrator", startPayload)

	c.JSON(http.StatusCreated, gin.H{
		"session_id": session.ID,
		"status":     session.Status,
		"objective":  session.CurrentObjective,
	})
}

// SendCommand sends a Command to the Session Orchestrator.
// POST /api/v1/workbench/sessions/:id/command
func (h *Handler) SendCommand(c *gin.Context) {
	sessionID := c.Param("id")
	orch, ok := h.sessions[sessionID]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "session not found"})
		return
	}

	var req struct {
		Type    CommandType     `json:"type" binding:"required"`
		Payload json.RawMessage `json:"payload"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	cmd := Command{
		ID:        ulid.Make().String(),
		SessionID: sessionID,
		Type:      req.Type,
		Payload:   req.Payload,
		IssuedAt:  time.Now(),
	}

	if err := orch.HandleCommand(c.Request.Context(), cmd); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Drain events and return them
	events := orch.DrainEvents()

	c.JSON(http.StatusOK, gin.H{
		"session": orch.GetSession(),
		"events":  events,
		"command": cmd.ID,
	})
}

// StreamSession establishes an SSE connection to stream WorkspaceRuntimeState patches.
// GET /api/v1/workbench/sessions/:id/stream
func (h *Handler) StreamSession(c *gin.Context) {
	sessionID := c.Param("id")
	orch, ok := h.sessions[sessionID]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "session not found"})
		return
	}

	// SSE Setup
	c.Writer.Header().Set("Content-Type", "text/event-stream")
	c.Writer.Header().Set("Cache-Control", "no-cache")
	c.Writer.Header().Set("Connection", "keep-alive")
	c.Writer.Header().Set("Transfer-Encoding", "chunked")

	// Subscribe to projector
	projector := orch.GetProjector()
	ch := projector.Subscribe()
	defer projector.Unsubscribe(ch)

	// Send initial state
	initialState := projector.GetState()
	initData, _ := json.Marshal(initialState)
	c.SSEvent("state", string(initData))
	c.Writer.Flush()

	clientGone := c.Writer.CloseNotify()

	for {
		select {
		case <-clientGone:
			return
		case patch := <-ch:
			patchData, _ := json.Marshal(patch)
			c.SSEvent("patch", string(patchData))
			c.Writer.Flush()
		}
	}
}

// GetSession returns the current session state.
// GET /api/v1/workbench/sessions/:id
func (h *Handler) GetSession(c *gin.Context) {
	sessionID := c.Param("id")
	orch, ok := h.sessions[sessionID]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "session not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"session": orch.GetSession(),
	})
}

// GetTimeline returns all events for a session.
// GET /api/v1/workbench/sessions/:id/timeline
func (h *Handler) GetTimeline(c *gin.Context) {
	sessionID := c.Param("id")
	orch, ok := h.sessions[sessionID]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "session not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"session_id": sessionID,
		"events":     orch.DrainEvents(),
		"snapshots":  orch.DrainSnapshots(),
	})
}
