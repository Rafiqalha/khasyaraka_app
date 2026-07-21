package handler

import (
	"fmt"
	"strings"

	"github.com/gin-gonic/gin"

	"github.com/pradigi/backend/internal/ai_agent"
	"github.com/pradigi/backend/internal/httputil"
)

type SubmitIntentRequest struct {
	QuestionID     string                 `json:"question_id" binding:"required"`
	ToolType       string                 `json:"tool_type" binding:"required"`
	UserPayload    map[string]interface{} `json:"user_payload" binding:"required"`
	History        []ai_agent.Message     `json:"history"`
	SessionScore   int                    `json:"session_score"`
	StreakCorrect  int                    `json:"streak_correct"`
	StreakWrong    int                    `json:"streak_wrong"`
	PreviousThreat string                 `json:"previous_threat"`
}

type PlayResponse struct {
	AIResponse *ai_agent.PradigiResponse   `json:"ai_response"`
	TokenUsage *ai_agent.TokenUsageTracker `json:"token_usage"`
}

type GameHandler struct {
	agent *ai_agent.Agent
}

func NewGameHandler(agent *ai_agent.Agent) *GameHandler {
	return &GameHandler{agent: agent}
}

func (h *GameHandler) HandlePlay(c *gin.Context) {
	var req SubmitIntentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httputil.BadRequest(c, "invalid request body: "+err.Error())
		return
	}

	userContext := buildGameMasterContext(req)

	pradigiResp, tokenUsage, err := h.agent.Execute(userContext, req.History)
	if err != nil {
		httputil.InternalError(c, err.Error())
		return
	}

	resp := PlayResponse{
		AIResponse: pradigiResp,
		TokenUsage: tokenUsage,
	}

	httputil.Success(c, resp, "evaluation complete")
}

func buildGameMasterContext(req SubmitIntentRequest) string {
	var sb strings.Builder
	sb.WriteString("[SESSION STATE]\n")
	sb.WriteString(fmt.Sprintf("Tool: %s\n", req.ToolType))
	sb.WriteString(fmt.Sprintf("Question ID: %s\n", req.QuestionID))
	sb.WriteString(fmt.Sprintf("Session Score: %d\n", req.SessionScore))
	sb.WriteString(fmt.Sprintf("Consecutive Correct: %d\n", req.StreakCorrect))
	sb.WriteString(fmt.Sprintf("Consecutive Wrong: %d\n", req.StreakWrong))
	if req.PreviousThreat != "" {
		sb.WriteString(fmt.Sprintf("Previous Threat: %s\n", req.PreviousThreat))
	}
	sb.WriteString(fmt.Sprintf("\n[OPERATOR ACTION]\n%v\n", req.UserPayload))
	sb.WriteString("\n[GAME MASTER DIRECTIVE]\n")
	sb.WriteString("As Game Master, evaluate the operator's action AND mutate the simulation environment.\n")
	sb.WriteString("Build an adaptive narrative that connects this action to the next threat scenario.\n")
	return sb.String()
}
