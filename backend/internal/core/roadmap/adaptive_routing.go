package roadmap

import (
	"context"
)

type RoutingAction struct {
	ActionType string // ADD_NODE, REMOVE_NODE, REPRIORITIZE
	NodeID     string
}

type AdaptiveRouter interface {
	RouteOnMemoryDecay(ctx context.Context, memoryNodeID string, currentState string) ([]RoutingAction, error)
	RouteOnCompetencyAchieved(ctx context.Context, skillNodeID string) ([]RoutingAction, error)
}

type router struct{}

func NewAdaptiveRouter() AdaptiveRouter {
	return &router{}
}

func (r *router) RouteOnMemoryDecay(ctx context.Context, memoryNodeID string, currentState string) ([]RoutingAction, error) {
	var actions []RoutingAction
	// If memory state drops to WORKING or EXPIRED, we inject a review node (Spaced Repetition)
	if currentState == "WORKING" || currentState == "EXPIRED" {
		actions = append(actions, RoutingAction{
			ActionType: "ADD_NODE",
			NodeID:     "review_" + memoryNodeID, // Mocking a review module injection
		})
	}
	return actions, nil
}

func (r *router) RouteOnCompetencyAchieved(ctx context.Context, skillNodeID string) ([]RoutingAction, error) {
	var actions []RoutingAction
	// If user is already competent, remove redundant beginner modules (Fast-track)
	actions = append(actions, RoutingAction{
		ActionType: "REMOVE_NODE",
		NodeID:     "intro_" + skillNodeID, // Mocking redundant node removal
	})
	return actions, nil
}
