package knowledge

// Concept represents a single node in the Knowledge Graph.
type Concept struct {
	ID             string          `json:"id" yaml:"id"`
	Title          string          `json:"title" yaml:"title"`
	Description    string          `json:"description" yaml:"description"`
	LearningAssets []LearningAsset `json:"learning_assets" yaml:"learning_assets"`
}

// LearningAsset acts as an abstraction between a Concept and its implementation (Mission, Notebook).
type LearningAsset struct {
	ID          string `json:"id" yaml:"id"`
	Type        string `json:"type" yaml:"type"`                 // "notebook", "mission", "simulation", "quiz", "animation"
	AcademyID   string `json:"academy_id" yaml:"academy_id"`     // E.g., "python_academy" or "global"
	ReferenceID string `json:"reference_id" yaml:"reference_id"` // ID of the actual asset file/record
}

// RelationType defines the edge types in the Knowledge Graph.
type RelationType string

const (
	RelRequires        RelationType = "requires"
	RelBuildsOn        RelationType = "builds_on"
	RelExplains        RelationType = "explains"
	RelUses            RelationType = "uses"
	RelImplements      RelationType = "implements"
	RelGeneralizes     RelationType = "generalizes"
	RelSpecializes     RelationType = "specializes"
	RelAnalogyOf       RelationType = "analogy_of"
	RelMisconceptionOf RelationType = "misconception_of"
	RelPartOf          RelationType = "part_of"
	RelExampleOf       RelationType = "example_of"
)

// Relation represents a directed edge between two concepts.
type Relation struct {
	SourceID string       `json:"source_id" yaml:"source_id"`
	TargetID string       `json:"target_id" yaml:"target_id"`
	Type     RelationType `json:"type" yaml:"type"`
}

// Graph represents a specific version of the Knowledge Graph.
// This allows reproducing past Adaptive Planner decisions.
type Graph struct {
	Version   string     `json:"version" yaml:"version"`
	Concepts  []Concept  `json:"concepts" yaml:"concepts"`
	Relations []Relation `json:"relations" yaml:"relations"`
}
