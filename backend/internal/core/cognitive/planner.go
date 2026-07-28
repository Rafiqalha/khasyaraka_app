package cognitive

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// PlannerRecommendation represents an adaptive next step formulated by analyzing cognitive gaps.
type PlannerRecommendation struct {
	RecommendationID string  `json:"recommendation_id"`
	SessionID        string  `json:"session_id"`
	TargetCapability string  `json:"target_capability"`
	RecommendedTitle string  `json:"recommended_title"`
	RecommendedType  string  `json:"recommended_type"` // TEACHING_SCENARIO, DEBUGGING_DRILL, ADVANCED_PRODUCTION
	Difficulty       float64 `json:"difficulty"`
	Rationale        string  `json:"rationale"`
}

const (
	EventPlannerRecommendationReady = "PlannerRecommendationReady"
)

// SmartPlanner diagnoses multi-dimensional competency gaps and prescribes adaptive mission trajectories.
// BOUNDARY RULE: Planner reads both Cognitive Graph (WHAT) and Learning Memory (HOW) to formulate next steps.
type SmartPlanner struct {
	memoryStore *LearningMemoryStore
	bus         kernel.EventBus
}

func NewSmartPlanner(memoryStore *LearningMemoryStore, bus kernel.EventBus) *SmartPlanner {
	return &SmartPlanner{
		memoryStore: memoryStore,
		bus:         bus,
	}
}

// OnEvent subscribes to EventCognitiveGraphUpdated emitted by CognitiveGraph.
func (p *SmartPlanner) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != EventCognitiveGraphUpdated {
		return nil
	}

	var node CognitiveNode
	if err := json.Unmarshal(event.Payload, &node); err != nil {
		return fmt.Errorf("failed to unmarshal CognitiveNode in SmartPlanner: %w", err)
	}

	logger.Info().Str("concept", node.ConceptID).Msg("Smart Planner diagnosing multidimensional cognitive gaps")

	rec := &PlannerRecommendation{
		RecommendationID: fmt.Sprintf("rec_%d", time.Now().UnixNano()),
		SessionID:        event.SessionID,
		TargetCapability: node.ConceptID,
	}

	// Rule 1: The Explainer Gap (High Implementation, Low Reflection)
	if node.Implementation >= 0.10 && node.Reflection < 0.10 {
		rec.RecommendedTitle = fmt.Sprintf("Teach another developer: Architecture Explanation of %s", node.ConceptID)
		rec.RecommendedType = "TEACHING_SCENARIO"
		rec.Difficulty = 0.50
		rec.Rationale = "Learner demonstrates implementation proficiency but lacks reflection/explanation capability."
	} else if node.Implementation >= 0.10 && node.Debugging < 0.10 {
		// Rule 2: The Debugging Gap (Can code from scratch, but struggles to read errors)
		rec.RecommendedTitle = fmt.Sprintf("Stack Trace Debugging Drill for %s", node.ConceptID)
		rec.RecommendedType = "DEBUGGING_DRILL"
		rec.Difficulty = 0.65
		rec.Rationale = "Learner needs practice reading production error traces and isolating failures."
	} else {
		// Rule 3: Balanced Mastery -> Advance to Production Grade
		rec.RecommendedTitle = fmt.Sprintf("Production Scale Implementation of %s", node.ConceptID)
		rec.RecommendedType = "ADVANCED_PRODUCTION"
		rec.Difficulty = 0.80
		rec.Rationale = "Balanced multi-dimensional mastery achieved; ready for high-difficulty production scenario."
	}

	logger.Info().
		Str("rec_type", rec.RecommendedType).
		Str("title", rec.RecommendedTitle).
		Msg("Smart Planner recommendation generated -> Emitting to OS Event Bus")

	if p.bus != nil {
		payloadBytes, _ := json.Marshal(rec)
		busEvent := kernel.Event{
			ID:        fmt.Sprintf("evt_rec_%d", time.Now().UnixNano()),
			SessionID: event.SessionID,
			Type:      EventPlannerRecommendationReady,
			Source:    "smart_planner_engine",
			Timestamp: time.Now(),
			Payload:   payloadBytes,
		}
		return p.bus.Publish(ctx, busEvent)
	}
	return nil
}
