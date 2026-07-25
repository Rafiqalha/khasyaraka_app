package sdk

// LearningWorldModel represents the complete Graph structures parsed from ontology/*.
// This becomes the primary payload loaded into the Learning World Model service.
type LearningWorldModel struct {
	KnowledgeGraph   *Graph `json:"knowledge_graph"`
	SkillGraph       *Graph `json:"skill_graph"`
	ConceptGraph     *Graph `json:"concept_graph"`
	SimulationGraph  *Graph `json:"simulation_graph"`
	EnvironmentGraph *Graph `json:"environment_graph"`
	ResourceGraph    *Graph `json:"resource_graph"`
}

// Graph is a generic directed graph representing relationships.
type Graph struct {
	Nodes []Node `json:"nodes"`
	Edges []Edge `json:"edges"`
}

// Node represents a single entity in a graph.
type Node struct {
	ID         string            `json:"id"`
	Type       string            `json:"type"` // e.g. "concept", "skill", "entity"
	Label      string            `json:"label"`
	Properties map[string]string `json:"properties"`
}

// Edge represents a relationship between two nodes.
type Edge struct {
	SourceID string `json:"source_id"`
	TargetID string `json:"target_id"`
	Relation string `json:"relation"` // e.g. "requires", "builds_upon", "simulates"
}
