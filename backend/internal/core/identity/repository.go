package identity

import (
	"database/sql"
	"github.com/jmoiron/sqlx"
)

type Repository interface {
	GetProfile(userID string) (*LearnerProfile, error)
	UpsertProfile(profile *LearnerProfile) error
	GetDevices(userID string) ([]UserDevice, error)
	AddDevice(device *UserDevice) error
	ClearDevices(userID string) error
	GetInterests(userID string) ([]UserInterest, error)
	AddInterest(interest *UserInterest) error
	ClearInterests(userID string) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) GetProfile(userID string) (*LearnerProfile, error) {
	var profile LearnerProfile
	err := r.db.Get(&profile, "SELECT * FROM learner_profiles WHERE user_id = $1", userID)
	if err == sql.ErrNoRows {
		return nil, ErrProfileNotFound
	}
	return &profile, err
}

func (r *repository) UpsertProfile(profile *LearnerProfile) error {
	query := `
		INSERT INTO learner_profiles (
			user_id, display_name, birth_year, country, timezone, native_language, 
			preferred_language, education_level, experience_level, career_slug, 
			learning_goal_type, learning_goal_detail, motivation_type, motivation_text, 
			daily_minutes, prefers_video, prefers_text, prefers_project, prefers_quiz, 
			ai_persona, current_stage, persona_version, identity_schema_version, 
			onboarding_completed, updated_at
		) VALUES (
			:user_id, :display_name, :birth_year, :country, :timezone, :native_language, 
			:preferred_language, :education_level, :experience_level, :career_slug, 
			:learning_goal_type, :learning_goal_detail, :motivation_type, :motivation_text, 
			:daily_minutes, :prefers_video, :prefers_text, :prefers_project, :prefers_quiz, 
			:ai_persona, :current_stage, :persona_version, :identity_schema_version, 
			:onboarding_completed, NOW()
		)
		ON CONFLICT (user_id) DO UPDATE SET
			display_name = EXCLUDED.display_name,
			birth_year = EXCLUDED.birth_year,
			country = EXCLUDED.country,
			timezone = EXCLUDED.timezone,
			native_language = EXCLUDED.native_language,
			preferred_language = EXCLUDED.preferred_language,
			education_level = EXCLUDED.education_level,
			experience_level = EXCLUDED.experience_level,
			career_slug = EXCLUDED.career_slug,
			learning_goal_type = EXCLUDED.learning_goal_type,
			learning_goal_detail = EXCLUDED.learning_goal_detail,
			motivation_type = EXCLUDED.motivation_type,
			motivation_text = EXCLUDED.motivation_text,
			daily_minutes = EXCLUDED.daily_minutes,
			prefers_video = EXCLUDED.prefers_video,
			prefers_text = EXCLUDED.prefers_text,
			prefers_project = EXCLUDED.prefers_project,
			prefers_quiz = EXCLUDED.prefers_quiz,
			ai_persona = EXCLUDED.ai_persona,
			current_stage = EXCLUDED.current_stage,
			persona_version = EXCLUDED.persona_version,
			identity_schema_version = EXCLUDED.identity_schema_version,
			onboarding_completed = EXCLUDED.onboarding_completed,
			updated_at = NOW();
	`
	_, err := r.db.NamedExec(query, profile)
	return err
}

func (r *repository) GetDevices(userID string) ([]UserDevice, error) {
	devices := []UserDevice{}
	err := r.db.Select(&devices, "SELECT * FROM user_devices WHERE user_id = $1", userID)
	return devices, err
}

func (r *repository) AddDevice(device *UserDevice) error {
	query := `INSERT INTO user_devices (user_id, platform, os, capability_score) VALUES (:user_id, :platform, :os, :capability_score)`
	_, err := r.db.NamedExec(query, device)
	return err
}

func (r *repository) ClearDevices(userID string) error {
	_, err := r.db.Exec("DELETE FROM user_devices WHERE user_id = $1", userID)
	return err
}

func (r *repository) GetInterests(userID string) ([]UserInterest, error) {
	interests := []UserInterest{}
	err := r.db.Select(&interests, "SELECT * FROM user_interests WHERE user_id = $1", userID)
	return interests, err
}

func (r *repository) AddInterest(interest *UserInterest) error {
	query := `INSERT INTO user_interests (user_id, interest) VALUES (:user_id, :interest)`
	_, err := r.db.NamedExec(query, interest)
	return err
}

func (r *repository) ClearInterests(userID string) error {
	_, err := r.db.Exec("DELETE FROM user_interests WHERE user_id = $1", userID)
	return err
}
