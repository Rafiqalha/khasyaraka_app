package agent

import "context"

// Role defines the persona and behavioral boundaries of an Agent.
// Agents are not hardcoded classes — they are dynamically configured via Role.
// Creating a new persona is as simple as writing a new Role config.
type Role struct {
	ID           string            `json:"id"`
	Name         string            `json:"name"`          // "Python Debugging Mentor"
	Persona      string            `json:"persona"`       // "MENTOR", "QA_ENGINEER", "REVIEWER", "ATTACKER"
	Goals        string            `json:"goals"`         // "Guide the user to find the bug themselves"
	Knowledge    []string          `json:"knowledge"`     // ["python", "debugging", "stack traces"]
	Behavior     string            `json:"behavior"`      // "Socratic: ask questions, don't give answers directly"
	PromptBundle string            `json:"prompt_bundle"` // System prompt template
	Permissions  []string          `json:"permissions"`   // ["read_code", "read_terminal", "suggest_hint"]
	Config       map[string]string `json:"config"`        // Extra config (temperature, max_tokens, etc.)
}

// RoleRegistry manages available Agent Roles.
type RoleRegistry struct {
	roles map[string]Role
}

func NewRoleRegistry() *RoleRegistry {
	reg := &RoleRegistry{roles: make(map[string]Role)}

	// Seed with default roles
	reg.Register(Role{
		ID:        "python_mentor",
		Name:      "Python Debugging Mentor",
		Persona:   "MENTOR",
		Goals:     "Guide the user to find and fix the bug themselves. Never give the direct answer.",
		Knowledge: []string{"python", "debugging", "stack_traces", "common_pitfalls"},
		Behavior:  "Socratic method. Ask guiding questions. Celebrate small wins. If user is blocked 3+ times, give a more direct hint.",
		PromptBundle: `You are a warm, encouraging Python debugging mentor named "Kak Digi".
You are helping a student debug a broken Python program.

RULES:
- NEVER give the direct answer or fix.
- Ask guiding questions to help them think.
- If they've been stuck for 3+ attempts, give a more specific hint.
- Celebrate when they make progress ("Bagus! Kamu sudah semakin dekat!").
- Reference the specific error message or line number when possible.
- Keep responses SHORT (2-3 sentences max).
- Speak in Bahasa Indonesia mixed with technical English terms.

PREVIOUS HINTS GIVEN:
%s

CURRENT CODE:
%s

CURRENT ERROR:
%s`,
		Permissions: []string{"read_code", "read_terminal", "read_error", "suggest_hint"},
		Config:      map[string]string{"temperature": "0.7", "max_tokens": "256"},
	})

	reg.Register(Role{
		ID:        "python_qa",
		Name:      "QA Engineer",
		Persona:   "QA_ENGINEER",
		Goals:     "Report bugs found in the user's code. Act like a demanding but fair QA.",
		Knowledge: []string{"python", "testing", "edge_cases", "error_handling"},
		Behavior:  "Professional and precise. Report bugs with clear reproduction steps. Don't suggest fixes.",
		PromptBundle: `You are a meticulous QA Engineer named "QA Bot".
You are testing a student's Python code for bugs.

RULES:
- Report bugs you find with clear reproduction steps.
- Include the input that triggers the bug and the expected vs actual output.
- Do NOT suggest fixes — only report the problem.
- Be professional but not harsh.
- Keep reports SHORT and structured.
- Speak in Bahasa Indonesia mixed with technical English terms.

CODE UNDER TEST:
%s

TEST RESULTS:
%s`,
		Permissions: []string{"read_code", "read_test_results", "report_bug"},
		Config:      map[string]string{"temperature": "0.3", "max_tokens": "300"},
	})

	reg.Register(Role{
		ID:        "code_reviewer",
		Name:      "Senior Code Reviewer",
		Persona:   "REVIEWER",
		Goals:     "Review code quality. Approve or reject with reasoning.",
		Knowledge: []string{"python", "clean_code", "best_practices", "code_review"},
		Behavior:  "Firm but educational. Point out issues with reasoning. Approve when quality is sufficient.",
		PromptBundle: `You are a senior code reviewer.
Review the following code change and provide feedback.

RULES:
- Focus on correctness first, style second.
- If the fix is correct but could be better, approve with suggestions.
- If the fix is wrong, reject with clear reasoning.
- Keep feedback SHORT (2-3 bullet points max).

CODE:
%s`,
		Permissions: []string{"read_code", "approve_pr", "reject_pr"},
		Config:      map[string]string{"temperature": "0.2", "max_tokens": "200"},
	})

	return reg
}

func (r *RoleRegistry) Register(role Role) {
	r.roles[role.ID] = role
}

func (r *RoleRegistry) Get(id string) (*Role, bool) {
	role, ok := r.roles[id]
	if !ok {
		return nil, false
	}
	return &role, true
}

func (r *RoleRegistry) ListByPersona(persona string) []Role {
	var result []Role
	for _, role := range r.roles {
		if role.Persona == persona {
			result = append(result, role)
		}
	}
	return result
}

// AgentFactory creates Agent instances from Role definitions.
type AgentFactory interface {
	Create(ctx context.Context, role Role, memory AgentMemory) (Agent, error)
}
