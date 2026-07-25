package runtime

import (
	"fmt"
	"sync"
)

type RuntimeState string

const (
	StateCreated      RuntimeState = "CREATED"
	StateProvisioning RuntimeState = "PROVISIONING"
	StateRunning      RuntimeState = "RUNNING"
	StatePaused       RuntimeState = "PAUSED"
	StateWaiting      RuntimeState = "WAITING"
	StateCompleted    RuntimeState = "COMPLETED"
	StateArchived     RuntimeState = "ARCHIVED"
)

// StateMachine manages strict, valid lifecycle state transitions for a Runtime Session.
type StateMachine struct {
	mu           sync.Mutex
	currentState RuntimeState
}

func NewStateMachine(initial RuntimeState) *StateMachine {
	if initial == "" {
		initial = StateCreated
	}
	return &StateMachine{currentState: initial}
}

func (sm *StateMachine) Current() RuntimeState {
	sm.mu.Lock()
	defer sm.mu.Unlock()
	return sm.currentState
}

// Transition performs a validated state transition. Returns error if invalid.
func (sm *StateMachine) Transition(next RuntimeState) (RuntimeState, error) {
	sm.mu.Lock()
	defer sm.mu.Unlock()

	valid := false
	switch sm.currentState {
	case StateCreated:
		valid = (next == StateProvisioning || next == StateRunning)
	case StateProvisioning:
		valid = (next == StateRunning || next == StatePaused)
	case StateRunning:
		valid = (next == StatePaused || next == StateWaiting || next == StateCompleted)
	case StatePaused:
		valid = (next == StateRunning || next == StateArchived)
	case StateWaiting:
		valid = (next == StateRunning || next == StateCompleted)
	case StateCompleted:
		valid = (next == StateArchived)
	case StateArchived:
		valid = false // Terminal state
	}

	if !valid {
		return sm.currentState, fmt.Errorf("invalid runtime state transition from %s to %s", sm.currentState, next)
	}

	sm.currentState = next
	return sm.currentState, nil
}
