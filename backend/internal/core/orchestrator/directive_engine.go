package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/ai_agent"
)

type DirectiveEngine interface {
	SynthesizeDirective(ctx context.Context, intelCtx IntelligenceContext) (*IntelligenceDirective, error)
}

type engine struct {
	aiClient *ai_agent.Client
}

func NewDirectiveEngine(aiClient *ai_agent.Client) DirectiveEngine {
	return &engine{
		aiClient: aiClient,
	}
}

func (e *engine) SynthesizeDirective(ctx context.Context, intelCtx IntelligenceContext) (*IntelligenceDirective, error) {
	// Construct the holistic context for the AI
	// MVP: Hardcode persona to 'SCOUT' or 'TECH' based on user ID or let Orchestrator fetch it.
	// We'll pass a default persona here for demonstration, you can fetch this from Identity Service later.
	userPersona := "SCOUT_ACADEMY (Anak Pramuka: Loves adventure, teamwork, tactical language)"
	if strings.Contains(intelCtx.UserID, "tech") {
		userPersona = "TECH_ACADEMY (Mahasiswa Data Sains: Pragmatic, efficiency-focused, data-driven)"
	}

	prompt := fmt.Sprintf(`
You are the "Pradigi Intelligence Orchestrator", the central AI mentor for a user.
Here is the user's current complete state:
- User Persona: %s
- Memory State: %s
- Roadmap State: %s
- Career State: %s
- Portfolio State: %s

Based on this holistic view, determine the SINGLE MOST IMPORTANT NEXT ACTION for the user to take.
Return ONLY a valid JSON object with EXACTLY these fields, no markdown, no backticks:
{
  "action_type": "URGENT_REVIEW" | "PORTFOLIO_BUILDING" | "RESUME_ROADMAP" | "LEARN_NEW_SKILL",
  "priority_score": <float between 0 and 10>,
  "reasoning": "Short 1-2 sentence explanation of why this is the priority.",
  "display": {
    "title": "Short catchy title matching the persona",
    "narrative": "A warm, exclusively tailored 2-3 sentence mentoring narrative based on their Persona. DO NOT scold them. Make it feel like an exclusive guidance.",
    "action_label": "Button text matching the persona vibe",
    "theme_color": "sand_orange" | "tech_blue" | "danger_red" | "success_green"
  }
}
	`, userPersona, string(intelCtx.MemoryStateJSON), string(intelCtx.RoadmapStateJSON), string(intelCtx.CareerStateJSON), string(intelCtx.PortfolioStateJSON))

	// Call DeepSeek
	messages := []ai_agent.Message{
		{Role: "system", Content: "You are a pragmatic, data-driven AI mentor."},
		{Role: "user", Content: prompt},
	}
	aiResponseStr, _, err := e.aiClient.Chat(ctx, messages)
	if err != nil {
		return nil, fmt.Errorf("failed to call AI: %w", err)
	}

	// Clean up JSON response
	cleanedResp := strings.TrimSpace(aiResponseStr)
	cleanedResp = strings.TrimPrefix(cleanedResp, "```json")
	cleanedResp = strings.TrimPrefix(cleanedResp, "```")
	cleanedResp = strings.TrimSuffix(cleanedResp, "```")
	cleanedResp = strings.TrimSpace(cleanedResp)

	// Parse JSON
	var aiDecision struct {
		ActionType    string  `json:"action_type"`
		PriorityScore float64 `json:"priority_score"`
		Reasoning     string  `json:"reasoning"`
		Display       struct {
			Title       string `json:"title"`
			Narrative   string `json:"narrative"`
			ActionLabel string `json:"action_label"`
			ThemeColor  string `json:"theme_color"`
		} `json:"display"`
	}

	if err := json.Unmarshal([]byte(cleanedResp), &aiDecision); err != nil {
		// Fallback if parsing fails
		aiDecision.ActionType = "RESUME_ROADMAP"
		aiDecision.PriorityScore = 1.0
		aiDecision.Reasoning = "Failed to parse AI response. Defaulting to resume roadmap."
		aiDecision.Display.Title = "Lanjutkan Perjalanan"
		aiDecision.Display.Narrative = "Mari kembali ke jalur belajarmu."
		aiDecision.Display.ActionLabel = "Lanjut Belajar"
		aiDecision.Display.ThemeColor = "tech_blue"
	}

	// Construct payload
	payloadBytes, _ := json.Marshal(aiDecision.Display)

	dir := &IntelligenceDirective{
		ID:               ulid.Make().String(),
		UserID:           intelCtx.UserID,
		ContextID:        intelCtx.ID,
		EpochID:          intelCtx.EpochID,
		ActionType:       aiDecision.ActionType,
		PriorityScore:    aiDecision.PriorityScore,
		DirectivePayload: payloadBytes,
		CreatedAt:        time.Now(),
	}

	return dir, nil
}
