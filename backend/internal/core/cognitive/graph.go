package cognitive

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// CognitiveNode represents a dynamic concept node within the user's internal learning model.
// BOUNDARY RULE: Cognitive Graph stores WHAT the user knows across multiple dimensions.
type CognitiveNode struct {
	ConceptID      string  `json:"concept_id"`
	OverallMastery float64 `json:"overall_mastery"` // 0.0 to 100.0 aggregate score
	Confidence     float64 `json:"confidence"`      // 0.0 to 1.0
	Implementation float64 `json:"implementation"`  // 0.0 to 1.0
	Debugging      float64 `json:"debugging"`       // 0.0 to 1.0
	Reflection     float64 `json:"reflection"`      // 0.0 to 1.0
}

const (
	EventCognitiveGraphUpdated = "CognitiveGraphUpdated"
)

// CognitiveGraph maintains the dynamic multi-dimensional network of user competencies.
type CognitiveGraph struct {
	nodes map[string]*CognitiveNode
	bus   kernel.EventBus
	mu    sync.RWMutex
}

func NewCognitiveGraph(bus kernel.EventBus) *CognitiveGraph {
	return &CognitiveGraph{
		nodes: make(map[string]*CognitiveNode),
		bus:   bus,
	}
}

// OnEvent subscribes to EventCapabilityDeltaGenerated emitted by CapabilityEngine.
func (g *CognitiveGraph) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != EventCapabilityDeltaGenerated {
		return nil
	}

	var delta CapabilityDelta
	if err := json.Unmarshal(event.Payload, &delta); err != nil {
		return fmt.Errorf("failed to unmarshal CapabilityDelta in CognitiveGraph: %w", err)
	}

	g.mu.Lock()
	node, exists := g.nodes[delta.TargetCapability]
	if !exists {
		node = &CognitiveNode{ConceptID: delta.TargetCapability}
		g.nodes[delta.TargetCapability] = node
	}

	// Apply multi-dimensional increments
	node.Implementation = clamp(node.Implementation + delta.Implementation)
	node.Debugging = clamp(node.Debugging + delta.Debugging)
	node.Reflection = clamp(node.Reflection + delta.Reflection)
	node.Confidence = clamp(node.Confidence + delta.Confidence)

	// Recalculate Overall Mastery (Weighted Formula: Impl 35%, Debug 30%, Reflect 20%, Conf 15%)
	node.OverallMastery = (0.35*node.Implementation + 0.30*node.Debugging + 0.20*node.Reflection + 0.15*node.Confidence) * 100.0
	g.mu.Unlock()

	logger.Info().
		Str("concept", node.ConceptID).
		Float64("overall_mastery", node.OverallMastery).
		Msg("Cognitive Graph node updated -> Emitting to OS Event Bus")

	if g.bus != nil {
		payloadBytes, _ := json.Marshal(node)
		busEvent := kernel.Event{
			ID:        fmt.Sprintf("evt_grf_%d", time.Now().UnixNano()),
			SessionID: delta.SessionID,
			Type:      EventCognitiveGraphUpdated,
			Source:    "cognitive_graph_engine",
			Timestamp: time.Now(),
			Payload:   payloadBytes,
		}
		return g.bus.Publish(ctx, busEvent)
	}
	return nil
}

func (g *CognitiveGraph) GetNode(conceptID string) *CognitiveNode {
	g.mu.RLock()
	defer g.mu.RUnlock()
	return g.nodes[conceptID]
}

func clamp(val float64) float64 {
	if val < 0.0 {
		return 0.0
	}
	if val > 1.0 {
		return 1.0
	}
	return val
}
