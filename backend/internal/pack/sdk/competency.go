package sdk

// CompetencyFramework represents the framework.yaml inside competencies/.
// It maps the domain skills and defines evaluation criteria.
type CompetencyFramework struct {
	DomainID     string       `yaml:"domain_id" json:"domain_id"`
	Competencies []Competency `yaml:"competencies" json:"competencies"`
}

type Competency struct {
	ID          string   `yaml:"id" json:"id"`
	Name        string   `yaml:"name" json:"name"`
	Description string   `yaml:"description" json:"description"`
	Level       string   `yaml:"level" json:"level"`               // e.g. "Beginner", "Intermediate", "Advanced"
	RequiredFor []string `yaml:"required_for" json:"required_for"` // IDs of Learning Goals
	Rubrics     []Rubric `yaml:"rubrics" json:"rubrics"`
}

type Rubric struct {
	Metric   string `yaml:"metric" json:"metric"`
	Criteria string `yaml:"criteria" json:"criteria"`
	Points   int    `yaml:"points" json:"points"`
}
