package planner

// ===========================
// Learning Planner (The Educator)
// Decides WHAT the user should learn next based on Competencies.
// Agnostic to Workbench and Technical Domains.
// ===========================

type LearningIntent struct {
	Objective          string   `json:"objective"`
	Reason             string   `json:"reason"`
	Priority           string   `json:"priority"` // HIGH, MEDIUM, LOW
	Horizon            string   `json:"horizon"`  // "2 weeks", "This session"
	TargetCompetencies []string `json:"target_competencies"`
}

type LearningPlanner struct {
	strategyPlanner *StrategyPlanner
}

func NewLearningPlanner() *LearningPlanner {
	return &LearningPlanner{
		strategyPlanner: NewStrategyPlanner(),
	}
}

// In a real system, this would take the full CompetencyGraph.
// For the vertical slice, we mock the competency input.
func (p *LearningPlanner) Plan(weakCompetencies []string, behaviorProfile interface{}) *LearningIntent {
	// 1. Identify weakest competency
	target := "General Debugging"
	if len(weakCompetencies) > 0 {
		target = weakCompetencies[0] // Simplify for now
	}

	// 2. Formulate intent
	intent := &LearningIntent{
		Objective:          "Improve " + target,
		Reason:             "Identified as weak competency requiring reinforcement.",
		Priority:           "HIGH",
		Horizon:            "Immediate",
		TargetCompetencies: []string{target},
	}

	return intent
}
