package agent

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/pradigi/backend/internal/ai_agent"
)

// LLMAgent is an Agent implementation backed by a Large Language Model (DeepSeek).
// It implements the full Observe → Think → Respond → Act → Reflect loop.
// Used for: Mentor, QA Engineer, Reviewer, Attacker, Interviewer, etc.
type LLMAgent struct {
	role        Role
	memory      AgentMemory
	llmClient   *ai_agent.Client
	lastObs     *Observation
	lastThought *Thought
}

// Ensure LLMAgent implements Agent at compile time.
var _ Agent = (*LLMAgent)(nil)

func NewLLMAgent(role Role, memory AgentMemory, llmClient *ai_agent.Client) *LLMAgent {
	return &LLMAgent{
		role:      role,
		memory:    memory,
		llmClient: llmClient,
	}
}

// Observe receives the current workbench context.
func (a *LLMAgent) Observe(ctx context.Context, obs Observation) error {
	a.lastObs = &obs
	return nil
}

// Think performs internal reasoning based on the observation.
func (a *LLMAgent) Think(ctx context.Context) (*Thought, error) {
	if a.lastObs == nil {
		return nil, fmt.Errorf("no observation to think about")
	}

	// Build context from memory
	var memoryContext strings.Builder
	hintCount := 0
	if v, ok := a.memory.Recall("hint_count"); ok {
		hintCount, _ = v.(int)
	}
	if v, ok := a.memory.Recall("previous_hints"); ok {
		memoryContext.WriteString(fmt.Sprintf("%v", v))
	}

	thought := &Thought{
		Analysis: fmt.Sprintf("User triggered %s. Hint count so far: %d. Memory: %s",
			a.lastObs.EventType, hintCount, memoryContext.String()),
		Intent: "provide_guidance",
	}

	// Adjust intent based on hint count
	if hintCount >= 3 {
		thought.Intent = "provide_direct_hint"
		thought.Confidence = 0.9
	} else {
		thought.Intent = "ask_guiding_question"
		thought.Confidence = 0.7
	}

	a.lastThought = thought
	return thought, nil
}

// Respond generates an outward-facing response via LLM.
func (a *LLMAgent) Respond(ctx context.Context, thought *Thought) (*Response, error) {
	if a.lastObs == nil {
		return nil, fmt.Errorf("no observation context")
	}

	// Build the prompt from the Role's PromptBundle
	sourceCode := a.lastObs.Context["source_code"]
	errorOutput := a.lastObs.Context["error_output"]

	// Recall previous hints from memory
	previousHints := ""
	if v, ok := a.memory.Recall("previous_hints"); ok {
		previousHints = fmt.Sprintf("%v", v)
	}
	if previousHints == "" {
		previousHints = "(none yet)"
	}

	// Format the prompt bundle with context
	systemPrompt := fmt.Sprintf(a.role.PromptBundle, previousHints, sourceCode, errorOutput)

	// Build user message from observation
	userMsg := fmt.Sprintf("Event: %s\nPayload: %v\nPlease respond.",
		a.lastObs.EventType, a.lastObs.Payload)

	messages := []ai_agent.Message{
		{Role: "system", Content: systemPrompt},
		{Role: "user", Content: userMsg},
	}

	llmResponse, _, err := a.llmClient.Chat(ctx, messages)
	if err != nil {
		return nil, fmt.Errorf("LLM call failed: %w", err)
	}

	// Update memory
	hintCount := 0
	if v, ok := a.memory.Recall("hint_count"); ok {
		hintCount, _ = v.(int)
	}
	hintCount++
	_ = a.memory.Remember("hint_count", hintCount)

	// Append to previous hints
	prev := ""
	if v, ok := a.memory.Recall("previous_hints"); ok {
		prev = fmt.Sprintf("%v", v)
	}
	_ = a.memory.Remember("previous_hints", prev+"\n- "+llmResponse)

	return &Response{
		AgentID:    a.role.ID,
		AgentRole:  a.role.Persona,
		Content:    llmResponse,
		ActionType: "AgentResponded",
	}, nil
}

// Act performs a side-effect. For LLM agents, this is typically a no-op.
func (a *LLMAgent) Act(ctx context.Context, response *Response) (*Action, error) {
	return nil, nil // LLM agents don't perform side-effects
}

// Reflect evaluates the Agent's own response quality.
func (a *LLMAgent) Reflect(ctx context.Context, action *Action) (*Reflection, error) {
	return &Reflection{
		WasHelpful: true,
		Notes:      "Response generated successfully via LLM.",
	}, nil
}

// ===========================
// Compiler Agent (Non-LLM, Deterministic)
// ===========================

// CompilerAgent wraps a Runtime execution result as an Agent.
// The Compiler "observes" code, "thinks" (compiles), and "responds" with errors.
type CompilerAgent struct {
	lastObs *Observation
}

var _ Agent = (*CompilerAgent)(nil)

func NewCompilerAgent() *CompilerAgent { return &CompilerAgent{} }

func (c *CompilerAgent) Observe(ctx context.Context, obs Observation) error {
	c.lastObs = &obs
	return nil
}

func (c *CompilerAgent) Think(ctx context.Context) (*Thought, error) {
	return &Thought{
		Analysis:   "Compiling user code.",
		Intent:     "compile",
		Confidence: 1.0,
	}, nil
}

func (c *CompilerAgent) Respond(ctx context.Context, thought *Thought) (*Response, error) {
	// Extract compilation result from observation payload
	stderr, _ := c.lastObs.Payload["stderr"].(string)
	exitCode, _ := c.lastObs.Payload["exit_code"].(json.Number)

	content := "Compilation successful."
	if stderr != "" {
		content = fmt.Sprintf("Compilation error:\n%s", stderr)
	}

	return &Response{
		AgentID:    "compiler",
		AgentRole:  "COMPILER",
		Content:    content,
		ActionType: string(exitCode),
	}, nil
}

func (c *CompilerAgent) Act(ctx context.Context, response *Response) (*Action, error) {
	return nil, nil
}

func (c *CompilerAgent) Reflect(ctx context.Context, action *Action) (*Reflection, error) {
	return &Reflection{WasHelpful: true, Notes: "Deterministic compilation."}, nil
}

// ===========================
// LLM Agent Factory
// ===========================

type LLMAgentFactory struct {
	llmClient *ai_agent.Client
}

func NewLLMAgentFactory(client *ai_agent.Client) AgentFactory {
	return &LLMAgentFactory{llmClient: client}
}

func (f *LLMAgentFactory) Create(ctx context.Context, role Role, memory AgentMemory) (Agent, error) {
	return NewLLMAgent(role, memory, f.llmClient), nil
}
