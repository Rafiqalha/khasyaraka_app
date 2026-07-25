package mission

import (
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"github.com/pradigi/backend/internal/modules/auth"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func (h *Handler) GenerateMission(c *gin.Context) {
	uid, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var req struct {
		Persona string `json:"persona"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		req.Persona = "beginner"
	}

	state, err := h.svc.GenerateMission(uid, req.Persona)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": state})
}

func (h *Handler) ProcessAction(c *gin.Context) {
	missionID := c.Param("id")

	var action MissionAction
	if err := c.ShouldBindJSON(&action); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid action"})
		return
	}

	result, err := h.svc.ProcessAction(missionID, action)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": result})
}

func (h *Handler) StreamMission(c *gin.Context) {
	missionID := c.Param("id")

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}
	defer conn.Close()

	ch := make(chan EnvironmentEvent, 20)
	h.svc.Subscribe(missionID, ch)
	defer h.svc.Unsubscribe(missionID, ch)

	state, err := h.svc.GetState(missionID)
	if err == nil {
		data, _ := json.Marshal(gin.H{"type": "state", "data": state})
		conn.WriteMessage(websocket.TextMessage, data)
	}

	for {
		select {
		case evt, ok := <-ch:
			if !ok {
				return
			}
			data, _ := json.Marshal(gin.H{"type": "event", "data": evt})
			if err := conn.WriteMessage(websocket.TextMessage, data); err != nil {
				return
			}
		case <-c.Request.Context().Done():
			return
		}
	}
}

func (h *Handler) GetState(c *gin.Context) {
	missionID := c.Param("id")
	state, err := h.svc.GetState(missionID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": state})
}

func (h *Handler) Terminal(c *gin.Context) {
	_ = c.Param("id")

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}
	defer conn.Close()

	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			return
		}

		var req struct {
			Command string `json:"command"`
		}
		if err := json.Unmarshal(msg, &req); err != nil {
			conn.WriteMessage(websocket.TextMessage, []byte("error: invalid command format"))
			continue
		}

		if req.Command == "" {
			conn.WriteMessage(websocket.TextMessage, []byte(""))
			continue
		}

		// output, execErr := sandbox.ExecuteCommand(req.Command)
		output := "Not implemented in legacy shell"
		var execErr error = nil
		if execErr != nil {
			if execErr.Error() == "Timeout Execution" {
				conn.WriteMessage(websocket.TextMessage, []byte("Timeout Execution"))
			} else {
				conn.WriteMessage(websocket.TextMessage, []byte("error: "+execErr.Error()))
			}
		} else {
			conn.WriteMessage(websocket.TextMessage, []byte(output))
		}
	}
}
