package adaptive

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
)

type PolicyRule struct {
	Condition map[string]string `json:"condition"`
	Action    string            `json:"action"`
}

type Recommendation struct {
	Action     string                 `json:"action"`
	Reason     string                 `json:"reason"`
	Priority   string                 `json:"priority"` // High, Medium, Low
	TargetNode string                 `json:"targetNode"`
	Metadata   map[string]interface{} `json:"metadata"` // estimatedTime, difficulty, objective
}

type PolicyEngine struct {
	Rules []PolicyRule
}

func NewPolicyEngine(rulesJson string) (*PolicyEngine, error) {
	var rules []PolicyRule
	if err := json.Unmarshal([]byte(rulesJson), &rules); err != nil {
		return nil, err
	}
	return &PolicyEngine{Rules: rules}, nil
}

func (pe *PolicyEngine) Evaluate(model *LearnerModel) *Recommendation {
	for _, rule := range pe.Rules {
		if evaluateCondition(rule.Condition, model) {
			// In a real implementation, we would map the action to a specific node,
			// generate a reason based on the matched conditions, and compute priority.
			// This is a simplified placeholder logic for the MVP.
			return &Recommendation{
				Action:     rule.Action,
				Reason:     fmt.Sprintf("Matched condition: %v", rule.Condition),
				Priority:   "High",
				TargetNode: "Dynamic_Node", // Would be resolved against Conditional Graph
				Metadata: map[string]interface{}{
					"estimatedTime": "5m",
					"difficulty":    "Adaptive",
				},
			}
		}
	}

	// Default recommendation if no rule matches
	return &Recommendation{
		Action:     "CONTINUE",
		Reason:     "No specific policy matched, continuing default path",
		Priority:   "Low",
		TargetNode: "Next_Linear_Node",
		Metadata:   map[string]interface{}{},
	}
}

// evaluateCondition handles simple string-based logical evaluations
// e.g., "confidence": "<0.6", "velocity": "STRUGGLING"
func evaluateCondition(condition map[string]string, model *LearnerModel) bool {
	for key, expr := range condition {
		if !evaluateField(key, expr, model) {
			return false // All conditions in the map are ANDed together
		}
	}
	return true
}

func evaluateField(key string, expr string, model *LearnerModel) bool {
	switch key {
	case "confidence":
		return evaluateFloat(model.CognitiveModel.Confidence.Score, expr)
	case "velocity":
		return string(model.BehavioralModel.Velocity) == expr
	case "attention.averageReadTime":
		return evaluateFloat(model.BehavioralModel.Attention.AverageReadTime, expr)
	default:
		// Unknown key
		return false
	}
}

func evaluateFloat(value float64, expr string) bool {
	if strings.HasPrefix(expr, "<") {
		target, err := strconv.ParseFloat(strings.TrimPrefix(expr, "<"), 64)
		if err == nil {
			return value < target
		}
	} else if strings.HasPrefix(expr, ">") {
		target, err := strconv.ParseFloat(strings.TrimPrefix(expr, ">"), 64)
		if err == nil {
			return value > target
		}
	} else if strings.HasPrefix(expr, "<=") {
		target, err := strconv.ParseFloat(strings.TrimPrefix(expr, "<="), 64)
		if err == nil {
			return value <= target
		}
	} else if strings.HasPrefix(expr, ">=") {
		target, err := strconv.ParseFloat(strings.TrimPrefix(expr, ">="), 64)
		if err == nil {
			return value >= target
		}
	} else if strings.HasPrefix(expr, "==") {
		target, err := strconv.ParseFloat(strings.TrimPrefix(expr, "=="), 64)
		if err == nil {
			return value == target
		}
	}
	return false
}
