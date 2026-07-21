// Package engine provides the Cognitive State FSM and Decision Graph Builder.
// Both are PROJECTIONS — they are built FROM Learning Activity events,
// not sources of Learning Activity events.
package engine

import (
	"context"
	"time"

	"github.com/pradigi/backend/internal/workbench/domain"
)

// ===========================
// Cognitive State FSM
// Deterministic, rule-based state machine.
// NOT an AI opinion — pure finite state machine logic.
// ===========================

// FSMTransitionRule defines when and how the machine transitions.
type FSMTransitionRule struct {
	FromState     domain.CognitiveStateValue
	TriggerEvents []string // Workbench event types that trigger this transition
	MinCount      int      // Minimum consecutive triggers required
	ToState       domain.CognitiveStateValue
}

// DefaultFSMRules is the canonical set of transition rules for the Workbench FSM.
// Validated against Contract v1 Cognitive State definitions.
var DefaultFSMRules = []FSMTransitionRule{
	// Consecutive Run with no file changes -> Blocked
	{FromState: domain.CognitiveStateFocused, TriggerEvents: []string{"ToolExecuted"}, MinCount: 4, ToState: domain.CognitiveStateBlocked},
	// First activity -> Exploring
	{FromState: "", TriggerEvents: []string{"MissionStarted"}, MinCount: 1, ToState: domain.CognitiveStateExploring},
	// File open or read -> Exploring
	{FromState: domain.CognitiveStateExploring, TriggerEvents: []string{"EnvironmentChanged"}, MinCount: 1, ToState: domain.CognitiveStateFocused},
	// Ask mentor -> Seeking Help
	{FromState: domain.CognitiveStateBlocked, TriggerEvents: []string{"AgentRequested"}, MinCount: 1, ToState: domain.CognitiveStateSeekingHelp},
	// After mentor responds, attempt a run -> Focused again
	{FromState: domain.CognitiveStateSeekingHelp, TriggerEvents: []string{"ToolExecuted"}, MinCount: 1, ToState: domain.CognitiveStateFocused},
	// Test passes -> Verifying
	{FromState: domain.CognitiveStateFocused, TriggerEvents: []string{"ObjectiveCompleted"}, MinCount: 1, ToState: domain.CognitiveStateVerifying},
	// Mission complete
	{FromState: domain.CognitiveStateVerifying, TriggerEvents: []string{"MissionCompleted"}, MinCount: 1, ToState: domain.CognitiveStateCompleted},
}

// CognitiveStateFSM is the engine that drives Cognitive State transitions.
type CognitiveStateFSM struct {
	rules       []FSMTransitionRule
	eventBuffer map[string]int // Counts consecutive events per type
}

func NewCognitiveStateFSM() *CognitiveStateFSM {
	return &CognitiveStateFSM{
		rules:       DefaultFSMRules,
		eventBuffer: make(map[string]int),
	}
}

// Transition evaluates if the incoming event triggers a state change.
// Returns the new state if a transition fires, nil otherwise.
func (fsm *CognitiveStateFSM) Transition(
	ctx context.Context,
	currentState domain.CognitiveStateValue,
	incomingEvent string,
) *domain.CognitiveStateValue {
	// Track consecutive event occurrences
	fsm.eventBuffer[incomingEvent]++

	for _, rule := range fsm.rules {
		if rule.FromState != currentState && rule.FromState != "" {
			continue
		}
		for _, trigger := range rule.TriggerEvents {
			if trigger == incomingEvent && fsm.eventBuffer[incomingEvent] >= rule.MinCount {
				// Reset buffer for this event after triggering
				fsm.eventBuffer[incomingEvent] = 0
				return &rule.ToState
			}
		}
	}
	return nil // No transition
}

// ===========================
// Decision Graph Builder (Projection Engine)
// Subscribes to Learning Activity events and builds the multi-actor Decision Graph.
// If the graph cache is destroyed, it can be rebuilt from Learning Activities.
// ===========================

type DecisionGraphBuilder struct{}

func NewDecisionGraphBuilder() *DecisionGraphBuilder {
	return &DecisionGraphBuilder{}
}

// AddNode appends a new decision node to the graph based on an incoming event.
func (b *DecisionGraphBuilder) AddNode(
	ctx context.Context,
	graph *domain.DecisionGraph,
	actorType string,
	actionType string,
	contextPayload map[string]any,
	learningActivityID *string,
) domain.DecisionNode {
	return domain.DecisionNode{
		GraphID:            graph.ID,
		ActorType:          actorType,
		ActionType:         actionType,
		LearningActivityID: learningActivityID,
		OccurredAt:         time.Now(),
	}
}

// AddEdge connects two nodes with a semantic edge type.
func (b *DecisionGraphBuilder) AddEdge(
	ctx context.Context,
	graph *domain.DecisionGraph,
	fromNodeID, toNodeID string,
	edgeType domain.EdgeType,
) domain.DecisionEdge {
	return domain.DecisionEdge{
		GraphID:    graph.ID,
		FromNodeID: fromNodeID,
		ToNodeID:   toNodeID,
		EdgeType:   edgeType,
	}
}
