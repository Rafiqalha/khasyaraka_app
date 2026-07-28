package mission_engine

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/pradigi/backend/internal/core/llm"
	"github.com/pradigi/backend/internal/core/pack"
)

// MissionPackage is the generated output from the AI.
type MissionPackage struct {
	Title             string            `json:"title"`
	Objective         string            `json:"objective"`
	Challenge         string            `json:"challenge"`
	RequiredPanels    []string          `json:"required_panels"`
	EvaluationRules   []string          `json:"evaluation_rules"`
	ReflectionPrompts []string          `json:"reflection_prompts"`
	SeedFiles         map[string]string `json:"seed_files"` // e.g., main.go initial code
}

// Engine acts as the generative AI layer that builds a Mission Package based on a Context.
type Engine struct {
	ai llm.Client
}

func NewEngine(ai llm.Client) *Engine {
	return &Engine{ai: ai}
}

// Generate generates a completely adaptive Mission Package using an LLM.
func (e *Engine) Generate(ctx context.Context, mctx *MissionContext) (*MissionPackage, error) {
	systemPrompt := `You are the Pradigi Mission Engine. Your task is to generate a Mission Package for a student.
Output MUST be valid JSON matching the exact schema required. Do NOT output markdown or backticks.
The mission must adhere strictly to the Pedagogy constraints and the Target Capability.`

	if mctx != nil && mctx.AIRules != nil {
		dynamicRules := pack.BuildSystemPrompt(mctx.AIRules, mctx.Plan.TargetCapability.Name)
		systemPrompt = systemPrompt + "\n\n" + dynamicRules
	}

	userPrompt := fmt.Sprintf(`
Target Capability: %s
Difficulty Level: %d

Pedagogy Rules:
- Strategy: %s
- Hint Strategy: %s
- Feedback: %s

Reference Concepts (Do NOT hallucinate outside of this):
%s

Reference Examples & Templates:
%s

Reference Rubrics:
%s

Generate a comprehensive MissionPackage JSON adhering to the provided models.`,
		mctx.Plan.TargetCapability.Name,
		mctx.Plan.Difficulty,
		mctx.Plan.Pedagogy.Strategy,
		mctx.Plan.Pedagogy.HintStrategy,
		mctx.Plan.Pedagogy.FeedbackType,
		mctx.ReferenceConcepts,
		mctx.ReferenceExamples,
		mctx.ReferenceRubrics,
	)
	jsonStr, _, _, err := e.ai.GenerateJSON(ctx, systemPrompt, userPrompt)
	if err != nil {
		return nil, fmt.Errorf("failed to generate mission: %w", err)
	}

	var pkg MissionPackage
	if err := json.Unmarshal([]byte(jsonStr), &pkg); err != nil {
		return nil, fmt.Errorf("failed to parse AI JSON output: %w", err)
	}

	return &pkg, nil
}
