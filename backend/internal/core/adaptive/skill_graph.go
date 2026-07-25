package adaptive

// SkillNode represents a specific skill in the competency graph.
type SkillNode struct {
	ID            string   `json:"id"`
	Concept       string   `json:"concept"`
	Description   string   `json:"description"`
	Prerequisites []string `json:"prerequisites"` // IDs of prerequisite skills
	NextSkills    []string `json:"next_skills"`   // IDs of downstream skills
}

// SkillGraph maintains the hierarchical structure of all skills.
type SkillGraph struct {
	Nodes map[string]SkillNode `json:"nodes"`
}

// AddNode adds a skill to the graph.
func (g *SkillGraph) AddNode(node SkillNode) {
	if g.Nodes == nil {
		g.Nodes = make(map[string]SkillNode)
	}
	g.Nodes[node.ID] = node
}

// GetNode retrieves a skill from the graph.
func (g *SkillGraph) GetNode(id string) (SkillNode, bool) {
	if g.Nodes == nil {
		return SkillNode{}, false
	}
	node, exists := g.Nodes[id]
	return node, exists
}
