package runtime

import (
	"context"
)

// PackNode represents the runtime state and initial data of a node, fetched from a Pack.
type PackNode struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	InitialCode string `json:"initialCode"`
	Language    string `json:"language"`
}

// PackRuntime is the abstraction layer over the Learning Packs.
// For the MVP, it might fetch directly from a simulated JSON mapping or DB,
// but the interface ensures the frontend/backend doesn't couple directly to DB models.
type PackRuntime interface {
	GetNode(ctx context.Context, nodeID string) (*PackNode, error)
}

// MemoryPackRuntime is a temporary MVP implementation that provides static node data.
// In the future, this will parse the actual Pack manifests and extract the node data.
type MemoryPackRuntime struct {
	nodes map[string]*PackNode
}

func NewMemoryPackRuntime() *MemoryPackRuntime {
	return &MemoryPackRuntime{
		nodes: map[string]*PackNode{
			"mission_sql_1": {
				ID:          "mission_sql_1",
				Title:       "SQL Injection",
				Description: "Fix the loop boundary so the last element is included. This is a common error in iteration logic where you might miss evaluating the last element due to strict boundary conditions.",
				InitialCode: "def sum_list(numbers):\n    total = 0\n    for i in range(len(numbers) - 1):\n        total += numbers[i]\n    return total",
				Language:    "python",
			},
		},
	}
}

func (m *MemoryPackRuntime) GetNode(ctx context.Context, nodeID string) (*PackNode, error) {
	node, exists := m.nodes[nodeID]
	if !exists {
		// Fallback for demo so we don't crash on unmapped node IDs
		return &PackNode{
			ID:          nodeID,
			Title:       "Adaptive Node",
			Description: "This node was generated adaptively. Complete the required logic.",
			InitialCode: "# Write your code here",
			Language:    "python",
		}, nil
	}
	return node, nil
}
