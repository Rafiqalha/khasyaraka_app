package identity

import (
	"time"
)

type LearnerProfile struct {
	UserID                string    `db:"user_id"`
	DisplayName           string    `db:"display_name"`
	BirthYear             int       `db:"birth_year"`
	Country               string    `db:"country"`
	Timezone              string    `db:"timezone"`
	NativeLanguage        string    `db:"native_language"`
	PreferredLanguage     string    `db:"preferred_language"`
	EducationLevel        string    `db:"education_level"`
	ExperienceLevel       string    `db:"experience_level"`
	CareerSlug            string    `db:"career_slug"`
	LearningGoalType      string    `db:"learning_goal_type"`
	LearningGoalDetail    string    `db:"learning_goal_detail"`
	MotivationType        string    `db:"motivation_type"`
	MotivationText        string    `db:"motivation_text"`
	DailyMinutes          int       `db:"daily_minutes"`
	PrefersVideo          bool      `db:"prefers_video"`
	PrefersText           bool      `db:"prefers_text"`
	PrefersProject        bool      `db:"prefers_project"`
	PrefersQuiz           bool      `db:"prefers_quiz"`
	AIPersona             string    `db:"ai_persona"`
	CurrentStage          string    `db:"current_stage"`
	PersonaVersion        string    `db:"persona_version"`
	IdentitySchemaVersion string    `db:"identity_schema_version"`
	OnboardingCompleted   bool      `db:"onboarding_completed"`
	CreatedAt             time.Time `db:"created_at"`
	UpdatedAt             time.Time `db:"updated_at"`
}

type UserDevice struct {
	ID              string    `db:"id"`
	UserID          string    `db:"user_id"`
	Platform        string    `db:"platform"`
	OS              string    `db:"os"`
	CapabilityScore string    `db:"capability_score"`
	CreatedAt       time.Time `db:"created_at"`
}

type UserInterest struct {
	ID        string    `db:"id"`
	UserID    string    `db:"user_id"`
	Interest  string    `db:"interest"`
	CreatedAt time.Time `db:"created_at"`
}
