package mission_compiler

import "github.com/pradigi/backend/internal/core/blueprint"

// MissionSpecification is the abstract output produced by the Mission Compiler.
// BOUNDARY RULE 2: Compiler MUST NOT know Flutter, Editor, Terminal, or UI components.
// It only maps capability targets to abstract runtime requirements (e.g., "coding", "api_testing", "reflection").
type MissionSpecification struct {
	MissionID           string              `json:"mission_id"`
	GoalID              string              `json:"goal_id"`
	Objective           string              `json:"objective"`
	RuntimeRequirements RuntimeRequirements `json:"runtime_requirements"`
	EvaluationRules     []string            `json:"evaluation_rules"`
	ScaffoldingLevel    string              `json:"scaffolding_level"`
	Metadata            map[string]string   `json:"metadata,omitempty"`
}

type RuntimeRequirements struct {
	Needs []string `json:"needs"` // Abstract capabilities needed: "coding", "api_testing", "reflection", "database", "browser"
}

// SpecificationBuilder compiles a declarative blueprint and snapshot into an abstract specification.
type SpecificationBuilder struct{}

func NewSpecificationBuilder() *SpecificationBuilder {
	return &SpecificationBuilder{}
}

// CompileBlueprint takes a declarative PackBlueprint and user capability snapshot,
// and derives the abstract runtime capabilities required without knowing any UI tools.
func (sb *SpecificationBuilder) CompileBlueprint(bp *blueprint.PackBlueprint, userCapabilities map[string]int) (*MissionSpecification, error) {
	needsMap := make(map[string]bool)
	var evaluationRules []string

	// Analyze capability targets and determine abstract runtime needs
	for _, target := range bp.CapabilityTargets {
		switch target {
		case "jwt_authentication", "rest_api", "middleware", "http_headers", "bearer_token", "authorization":
			needsMap["coding"] = true
			needsMap["api_testing"] = true
			evaluationRules = append(evaluationRules, "validate_"+target)
		case "sql_queries", "database_schema", "migrations":
			needsMap["coding"] = true
			needsMap["database"] = true
			evaluationRules = append(evaluationRules, "verify_db_"+target)
		case "ui_layout", "responsive_design", "canvas_rendering":
			needsMap["visualization"] = true
			needsMap["browser"] = true
			evaluationRules = append(evaluationRules, "check_layout_"+target)
		default:
			needsMap["coding"] = true
		}
	}

	// Analyze evidence required
	for _, ev := range bp.EvidenceRequired {
		if ev == "reflection" || ev == "debugging_log" || ev == "debugging" {
			needsMap["reflection"] = true
		}
	}

	// Ensure reflection is present for continuous learning loop
	needsMap["reflection"] = true

	var needs []string
	for k := range needsMap {
		needs = append(needs, k)
	}

	return &MissionSpecification{
		MissionID: "msn_auto_" + bp.ID,
		GoalID:    bp.ID,
		Objective: "Master target capabilities: " + bp.ID,
		RuntimeRequirements: RuntimeRequirements{
			Needs: needs,
		},
		EvaluationRules:  evaluationRules,
		ScaffoldingLevel: "adaptive",
	}, nil
}
