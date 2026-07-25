package passport

import (
	"time"

	"github.com/pradigi/backend/internal/core/credential"
	"github.com/pradigi/backend/internal/core/learning_graph"
)

// VisibilitySettings controls what parts of the passport are public.
type VisibilitySettings struct {
	ShowCredentials  bool `json:"show_credentials"`
	ShowCompetencies bool `json:"show_competencies"`
	ShowEvidence     bool `json:"show_evidence"`
	ShowReflection   bool `json:"show_reflection"`
	ShowProjects     bool `json:"show_projects"`
}

// SkillPassport is the aggregated view of a user's entire learning journey and verified credentials.
type SkillPassport struct {
	UserID      string                  `json:"user_id"`
	Visibility  VisibilitySettings      `json:"visibility"`
	Credentials []credential.Credential `json:"credentials"`
	// We might only want to export the latest AssessmentSnapshots or a computed Graph
	CompetencyGraph map[string]interface{} `json:"competency_graph"`
	LearningGraph   learning_graph.Graph   `json:"learning_graph"`
	LastVerified    time.Time              `json:"last_verified"`
}
