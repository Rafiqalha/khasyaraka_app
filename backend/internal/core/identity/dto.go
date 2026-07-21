package identity

type UpdateProfileRequest struct {
	DisplayName        *string `json:"display_name,omitempty"`
	BirthYear          *int    `json:"birth_year,omitempty"`
	Country            *string `json:"country,omitempty"`
	Timezone           *string `json:"timezone,omitempty"`
	NativeLanguage     *string `json:"native_language,omitempty"`
	PreferredLanguage  *string `json:"preferred_language,omitempty"`
	EducationLevel     *string `json:"education_level,omitempty"`
	ExperienceLevel    *string `json:"experience_level,omitempty"`
	CareerSlug         *string `json:"career_slug,omitempty"`
	LearningGoalType   *string `json:"learning_goal_type,omitempty"`
	LearningGoalDetail *string `json:"learning_goal_detail,omitempty"`
	MotivationType     *string `json:"motivation_type,omitempty"`
	MotivationText     *string `json:"motivation_text,omitempty"`
	DailyMinutes       *int    `json:"daily_minutes,omitempty"`
	PrefersVideo       *bool   `json:"prefers_video,omitempty"`
	PrefersText        *bool   `json:"prefers_text,omitempty"`
	PrefersProject     *bool   `json:"prefers_project,omitempty"`
	PrefersQuiz        *bool   `json:"prefers_quiz,omitempty"`
	AIPersona          *string `json:"ai_persona,omitempty"`
	CurrentStage       *string `json:"current_stage,omitempty"`
}

type DeviceRequest struct {
	Platform        string `json:"platform"`
	OS              string `json:"os"`
	CapabilityScore string `json:"capability_score"`
}

type OnboardingRequest struct {
	Profile   UpdateProfileRequest `json:"profile"`
	Devices   []DeviceRequest      `json:"devices"`
	Interests []string             `json:"interests"`
}

type ProfileResponse struct {
	Profile   *LearnerProfile `json:"profile"`
	Devices   []UserDevice    `json:"devices"`
	Interests []UserInterest  `json:"interests"`
}
