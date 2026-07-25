package catalog

import "time"

type Goal struct {
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

type Academy struct {
	ID          string    `json:"id" db:"id"`
	Title       string    `json:"title" db:"title"`
	Description string    `json:"description" db:"description"`
	Icon        string    `json:"icon" db:"icon"`
	ColorTheme  string    `json:"color_theme" db:"color_theme"`
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

type Experience struct {
ID          string `yaml:"id" json:"id"`
Title       string `yaml:"title" json:"title"`
Description string `yaml:"description" json:"description"`
}

type ExecutionIntent struct {
ID          string `yaml:"id" json:"id"`
Title       string `yaml:"title" json:"title"`
Description string `yaml:"description" json:"description"`
}
