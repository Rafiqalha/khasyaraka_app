package academy

import (
	"time"
)

type Academy struct {
	ID          string    `json:"id" db:"id"`
	Title       string    `json:"title" db:"title"`
	Description string    `json:"description" db:"description"`
	Icon        string    `json:"icon" db:"icon"`
	ColorTheme  string    `json:"color_theme" db:"color_theme"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

type Domain struct {
	ID          string    `json:"id" db:"id"`
	AcademyID   string    `json:"academy_id" db:"academy_id"`
	Title       string    `json:"title" db:"title"`
	Description string    `json:"description" db:"description"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

type Specialization struct {
	ID          string    `json:"id" db:"id"`
	DomainID    string    `json:"domain_id" db:"domain_id"`
	Title       string    `json:"title" db:"title"`
	Description string    `json:"description" db:"description"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

type LearningGoal struct {
	ID                string    `json:"id" db:"id"`
	SpecializationID  string    `db:"specialization_id" json:"specialization_id"`
	Title             string    `db:"title" json:"title"`
	Slug              string    `db:"slug" json:"slug"`
	Status            string    `db:"status" json:"status"`
	Description       *string   `db:"description" json:"description"`
	LearningObjective *string   `db:"learning_objective" json:"learning_objective"`
	GoalType          *string   `db:"goal_type" json:"goal_type"`
	LatestPackID      *string   `db:"latest_pack_id" json:"latest_pack_id"`
	CreatedAt         time.Time `json:"created_at" db:"created_at"`
	UpdatedAt         time.Time `json:"updated_at" db:"updated_at"`
}

type Pack struct {
	ID             string    `json:"id" db:"id"`
	LearningGoalID string    `json:"learning_goal_id" db:"learning_goal_id"`
	Version        string    `json:"version" db:"version"`
	Manifest       []byte    `json:"manifest" db:"manifest"` // JSONB
	StorageURL     string    `json:"storage_url" db:"storage_url"`
	Checksum       string    `json:"checksum" db:"checksum"`
	Signature      string    `json:"signature" db:"signature"`
	Status         string    `json:"status" db:"status"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time `json:"updated_at" db:"updated_at"`
}

// Tree Structures for API Responses
type Intent struct {
	Academy         string `json:"academy" binding:"required"`
	Specialization  string `json:"specialization" binding:"required"`
	Mission         string `json:"mission" binding:"required"`
	Experience      string `json:"experience" binding:"required"`
	ExecutionIntent string `json:"execution_intent" binding:"required"`
}

type Context struct {
	Device     string `json:"device"`
	Locale     string `json:"locale"`
	Timezone   string `json:"timezone"`
	Entrypoint string `json:"entrypoint"`
}

type Session struct {
	ClientSessionID string `json:"client_session_id"`
	AppVersion      string `json:"app_version"`
	CatalogVersion  string `json:"catalog_version"`
}

type InitializeProfileRequest struct {
	Version int     `json:"version"`
	Intent  Intent  `json:"intent" binding:"required"`
	Context Context `json:"context"`
	Session Session `json:"session"`
}

type DirectorInsight struct {
	Observation string `json:"observation"`
	Motivation  string `json:"motivation"`
	Strategy    string `json:"strategy"`
	Reflection  string `json:"reflection"`
}

type DirectorBrief struct {
	Yesterday       string `json:"yesterday"`
	Today           string `json:"today"`
	Risk            string `json:"risk"`
	Focus           string `json:"focus"`
	ExpectedOutcome string `json:"expected_outcome"`
}

type ActiveRuntimeInfo struct {
	RuntimeID         string         `json:"runtime_id"`
	Title             string         `json:"title"`
	Status            string         `json:"status"` // RUNNING, PAUSED, WAITING, COMPILING, GENERATING
	CurrentObjective  string         `json:"current_objective"`
	LastActivityText  string         `json:"last_activity_text"`
	EstimatedDuration string         `json:"estimated_duration"` // Dynamic Planner calculation
	UserDifficulty    string         `json:"user_difficulty"`    // Dynamic Planner calculation
	DirectorBrief     *DirectorBrief `json:"director_brief,omitempty"`
}

type HomeResponse struct {
	RequiresInitialization bool               `json:"requires_initialization"`
	IsCalculating          bool               `json:"is_calculating"`
	GoalTitle              string             `json:"goal_title"`
	CurrentNode            string             `json:"current_node"`
	MasteredCompetencies   int                `json:"mastered_competencies"`
	RemainingCompetencies  int                `json:"remaining_competencies"`
	CurrentUnderstanding   []string           `json:"current_understanding"`
	MissingCompetencies    []string           `json:"missing_competencies"`
	DirectorInsight        *DirectorInsight   `json:"director_insight,omitempty"`
	ActiveJourney          *ActiveJourneyData `json:"active_journey,omitempty"`
	ActiveRuntime          *ActiveRuntimeInfo `json:"active_runtime,omitempty"`
	KnowledgeUpdateCount   int                `json:"knowledge_update_count"`
}

type LearningProfile struct {
	UserID         string    `json:"user_id" db:"user_id"`
	Goal           string    `json:"goal" db:"goal"`
	Experience     string    `json:"experience" db:"experience"`
	Endgame        string    `json:"endgame" db:"endgame"`
	LearningGoalID string    `json:"learning_goal_id" db:"learning_goal_id"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	UpdatedAt      time.Time `json:"updated_at" db:"updated_at"`
}
type LearningGoalTree struct {
	LearningGoal
	LatestPack *Pack `json:"latest_pack,omitempty"`
}

type SpecializationTree struct {
	Specialization
	LearningGoals []LearningGoalTree `json:"learning_goals"`
}

type DomainTree struct {
	Domain
	Specializations []SpecializationTree `json:"specializations"`
}

type AcademyTree struct {
	Academy
	Domains []DomainTree `json:"domains"`
}

// OS Workspace Response Models
