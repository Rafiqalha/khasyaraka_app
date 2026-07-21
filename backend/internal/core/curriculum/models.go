package curriculum

import "time"

// ===========================
// Curriculum Manifest Models
// Represents the static knowledge structure.
// This is parsed from Git/YAML manifests in academies/ workspace.
// ===========================

// Curriculum represents a complete educational program.
type Curriculum struct {
	ID                 string              `json:"id" yaml:"id"`
	AcademyID          string              `json:"academy_id" yaml:"-"`
	Title              string              `json:"title" yaml:"title"`
	Description        string              `json:"description" yaml:"description"`
	Version            string              `json:"version" yaml:"version"`
	LearningObjectives []LearningObjective `json:"learning_objectives" yaml:"learning_objectives"`
	Units              []Unit              `json:"units" yaml:"units"`
	CreatedAt          time.Time           `json:"created_at" yaml:"created_at"`
}

// LearningObjective represents a specific outcome mapped to a Competency.
type LearningObjective struct {
	ID           string `json:"id" yaml:"id"`
	CompetencyID string `json:"competency_id" yaml:"competency_id"`
	Title        string `json:"title" yaml:"title"`
	Description  string `json:"description" yaml:"description"`
}

// Unit is a major logical grouping within a curriculum (e.g., "01_fundamentals")
type Unit struct {
	ID          string   `json:"id" yaml:"id"`
	Title       string   `json:"title" yaml:"title"`
	Description string   `json:"description" yaml:"description"`
	Lessons     []Lesson `json:"lessons" yaml:"lessons"`
}

// Lesson is a specific topic within a Unit, containing a sequence of learning nodes.
type Lesson struct {
	ID                  string   `json:"id" yaml:"id"`
	Title               string   `json:"title" yaml:"title"`
	Difficulty          string   `json:"difficulty" yaml:"difficulty"`
	LearningObjectiveID string   `json:"learning_objective_id" yaml:"learning_objective_id"`
	Nodes               []Node   `json:"nodes" yaml:"nodes"`
}

// Node represents an executable learning activity.
// It can be a Notebook, Practice, Mission, Reflection, Checkpoint, or Evidence.
type Node struct {
	ID          string      `json:"id" yaml:"id"`
	Type        NodeType    `json:"type" yaml:"type"`
	Title       string      `json:"title" yaml:"title"`
	ContentRef  string      `json:"content_ref" yaml:"content_ref"` // Path to markdown/yaml file
	Constraints interface{} `json:"constraints,omitempty" yaml:"constraints,omitempty"`
}

type NodeType string

const (
	NodeTypeNotebook   NodeType = "NOTEBOOK"
	NodeTypePractice   NodeType = "PRACTICE"
	NodeTypeMission    NodeType = "MISSION"
	NodeTypeReflection NodeType = "REFLECTION"
	NodeTypeEvidence   NodeType = "EVIDENCE"
	NodeTypeCheckpoint NodeType = "CHECKPOINT"
)
