package studio

// CreateNotebookCommand represents an action from the Academy Studio.
type CreateNotebookCommand struct {
	AcademyID string `json:"academy_id"`
	ConceptID string `json:"concept_id"`
	Title     string `json:"title"`
}

// UpdateBlockCommand modifies an existing block in a notebook.
type UpdateBlockCommand struct {
	AcademyID string `json:"academy_id"`
	AssetID   string `json:"asset_id"`
	BlockID   string `json:"block_id"`
	Type      string `json:"type"` // e.g., "markdown", "sandbox"
	Content   string `json:"content"`
}

// MoveBlockCommand changes the order of blocks.
type MoveBlockCommand struct {
	AcademyID string `json:"academy_id"`
	AssetID   string `json:"asset_id"`
	BlockID   string `json:"block_id"`
	NewIndex  int    `json:"new_index"`
}

// PreviewAdaptiveExperienceCommand simulates what a student would see.
type PreviewAdaptiveExperienceCommand struct {
	AcademyID   string `json:"academy_id"`
	NodeID      string `json:"node_id"`
	PersonaType string `json:"persona_type"` // e.g., "high_ai_dependency", "expert"
}
