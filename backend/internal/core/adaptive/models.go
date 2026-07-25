package adaptive

// AdaptationPlan defines how a learning node should be rendered.
// This is generated deterministically by the Planner, NOT by an LLM.
type AdaptationPlan struct {
	Difficulty        string `json:"difficulty"` // "easy", "medium", "hard"
	NeedAnalogy       bool   `json:"need_analogy"`
	NeedVisualization bool   `json:"need_visualization"`
	MissionConstraint string `json:"mission_constraint"` // e.g., "AI Budget 1"
	ReflectionDepth   string `json:"reflection_depth"`   // "low", "high"
	EstimatedTimeMins int    `json:"estimated_time_mins"`
}
