// Package agent defines the universal Agent contract for the Cognitive Workbench.
// Every actor that changes state in the Workbench — whether an LLM, a compiler,
// a linter, a human reviewer, or a unit test runner — implements this interface.
package agent

import "context"

// Observation is what an Agent perceives from the Workbench environment.
type Observation struct {
	SessionID    string            `json:"session_id"`
	EventType    string            `json:"event_type"`
	ActorTrigger string            `json:"actor_trigger"`
	Payload      map[string]any    `json:"payload"`
	Context      map[string]string `json:"context"` // Current file, terminal output, etc.
}

// Thought is the internal reasoning step of an Agent.
type Thought struct {
	Analysis   string  `json:"analysis"`
	Intent     string  `json:"intent"`
	Confidence float64 `json:"confidence"`
}

// Response is the outward-facing output of an Agent — emitted as a Workbench Event.
type Response struct {
	AgentID    string `json:"agent_id"`
	AgentRole  string `json:"agent_role"`  // "MENTOR", "QA", "COMPILER", "LINTER"
	Content    string `json:"content"`     // Text, code, log output, etc.
	ActionType string `json:"action_type"` // The WorkbenchEventType this emits
}

// Action is a side-effect the Agent performs in the environment.
type Action struct {
	ToolName string         `json:"tool_name"`
	Params   map[string]any `json:"params"`
}

// Reflection is the Agent's post-hoc analysis of its own response.
type Reflection struct {
	WasHelpful  bool   `json:"was_helpful"`
	ShouldRetry bool   `json:"should_retry"`
	Notes       string `json:"notes"`
}

// Agent is the universal contract for every actor in the Workbench.
// Implements the Observe-Think-Respond-Act-Reflect cognitive loop.
// All implementations — LLM, Compiler, Linter, Static Analyzer — share this interface.
type Agent interface {
	// Observe receives the current workbench context.
	Observe(ctx context.Context, obs Observation) error

	// Think performs internal reasoning based on the observation.
	Think(ctx context.Context) (*Thought, error)

	// Respond generates an outward-facing Workbench Event.
	Respond(ctx context.Context, thought *Thought) (*Response, error)

	// Act performs a side-effect in the environment (optional, may be no-op).
	Act(ctx context.Context, response *Response) (*Action, error)

	// Reflect evaluates the quality of the Agent's own response.
	Reflect(ctx context.Context, action *Action) (*Reflection, error)
}

// AgentMemory defines ephemeral memory for an Agent within a single session.
// Scoped to the Experiment/Mission — cleared when session ends.
type AgentMemory interface {
	// Remember stores a fact about this session.
	Remember(key string, value any) error
	// Recall retrieves a stored fact.
	Recall(key string) (any, bool)
	// ClearAll wipes memory at end of session.
	ClearAll()
}

// InMemoryAgentMemory is the default ephemeral implementation.
type InMemoryAgentMemory struct {
	store map[string]any
}

func NewInMemoryAgentMemory() AgentMemory {
	return &InMemoryAgentMemory{store: make(map[string]any)}
}

func (m *InMemoryAgentMemory) Remember(key string, value any) error {
	m.store[key] = value
	return nil
}

func (m *InMemoryAgentMemory) Recall(key string) (any, bool) {
	v, ok := m.store[key]
	return v, ok
}

func (m *InMemoryAgentMemory) ClearAll() {
	m.store = make(map[string]any)
}
