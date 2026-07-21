package session

import (
	"encoding/json"
	"sync"
	"time"
)

// ===========================
// Workspace Runtime State Projection
// Represents the unified, real-time state of the Cognitive Workbench.
// Flattens raw events into a single renderable state for the client.
// ===========================

type WorkspaceRuntimeState struct {
	Version   int64           `json:"version"`
	Mission   MissionState    `json:"mission"`
	Runtime   RuntimeState    `json:"runtime"`
	Terminal  TerminalState   `json:"terminal"`
	Timeline  []TimelineEvent `json:"timeline"`
	Mentor    MentorState     `json:"mentor"`
	UpdatedAt time.Time       `json:"updated_at"`
}

type MissionState struct {
	ID        string `json:"id"`
	Status    string `json:"status"` // "ACTIVE", "COMPLETED", "ABANDONED"
	Objective string `json:"objective"`
	AIBudget  int    `json:"ai_budget"`
}

type RuntimeState struct {
	Status string `json:"status"` // "IDLE", "PREPARING", "RUNNING", "ERROR"
}

type TerminalState struct {
	// Instead of sending the full log every time, we might just send the delta
	// But in the full state projection, it holds everything (or a limited buffer).
	Output []string `json:"output"`
}

type TimelineEvent struct {
	ID        string    `json:"id"`
	Timestamp time.Time `json:"timestamp"`
	Type      string    `json:"type"` // e.g., "Thinking", "Blocked", "Asked Mentor", "Recovered", "Solved"
	Summary   string    `json:"summary"`
}

type MentorState struct {
	IsTyping    bool          `json:"is_typing"`
	ChatHistory []ChatMessage `json:"chat_history"`
}

type ChatMessage struct {
	ID     string `json:"id"`
	Sender string `json:"sender"` // "User", "Mentor", "System"
	Text   string `json:"text"`
}

// StatePatch is what is sent over SSE.
type StatePatch struct {
	Version int64           `json:"version"`
	Delta   json.RawMessage `json:"delta"` // JSON patch or partial object
}

// StateProjector listens to Session Orchestrator events and updates the state.
type StateProjector struct {
	mu    sync.RWMutex
	state WorkspaceRuntimeState

	// Broadcast channel for SSE handlers
	subscribers map[chan StatePatch]bool
}

func NewStateProjector(initialMissionID string, initialObjective string, aiBudget int) *StateProjector {
	return &StateProjector{
		state: WorkspaceRuntimeState{
			Version: 1,
			Mission: MissionState{
				ID:        initialMissionID,
				Status:    "ACTIVE",
				Objective: initialObjective,
				AIBudget:  aiBudget,
			},
			Runtime: RuntimeState{
				Status: "IDLE",
			},
			Terminal: TerminalState{
				Output: []string{},
			},
			Timeline: []TimelineEvent{},
			Mentor: MentorState{
				IsTyping:    false,
				ChatHistory: []ChatMessage{},
			},
			UpdatedAt: time.Now(),
		},
		subscribers: make(map[chan StatePatch]bool),
	}
}

func (p *StateProjector) Subscribe() chan StatePatch {
	p.mu.Lock()
	defer p.mu.Unlock()
	ch := make(chan StatePatch, 100) // Buffer to prevent blocking
	p.subscribers[ch] = true
	return ch
}

func (p *StateProjector) Unsubscribe(ch chan StatePatch) {
	p.mu.Lock()
	defer p.mu.Unlock()
	delete(p.subscribers, ch)
	close(ch)
}

func (p *StateProjector) GetState() WorkspaceRuntimeState {
	p.mu.RLock()
	defer p.mu.RUnlock()
	return p.state
}

// Update mutates the state and broadcasts a patch.
func (p *StateProjector) Update(updater func(state *WorkspaceRuntimeState)) {
	p.mu.Lock()
	defer p.mu.Unlock()

	updater(&p.state)
	p.state.Version++
	p.state.UpdatedAt = time.Now()

	// In a real implementation, we would generate a true JSON Patch (RFC 6902).
	// For this vertical slice, we just send the full updated state as the delta to keep it simple,
	// but the structure supports migrating to true patches.
	delta, _ := json.Marshal(p.state)

	patch := StatePatch{
		Version: p.state.Version,
		Delta:   delta,
	}

	for ch := range p.subscribers {
		select {
		case ch <- patch:
		default:
			// Drop if subscriber is too slow to avoid blocking
		}
	}
}
