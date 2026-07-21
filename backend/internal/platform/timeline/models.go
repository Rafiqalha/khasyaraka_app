package timeline

type Node struct {
	ID        string `json:"id"`
	Type      string `json:"type"` // e.g., 'Observation', 'Evidence', 'Activity'
	Label     string `json:"label"`
	Timestamp string `json:"timestamp"`
}

type Edge struct {
	SourceID string `json:"source_id"`
	TargetID string `json:"target_id"`
	Relation string `json:"relation"` // e.g., 'DERIVED_FROM', 'EXTRACTED_FROM'
}

type Explanation struct {
	RootID  string `json:"root_id"`
	Nodes   []Node `json:"nodes"`
	Edges   []Edge `json:"edges"`
	Summary string `json:"summary"`
}
