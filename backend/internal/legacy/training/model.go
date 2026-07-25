package training

type Course struct {
	ID          string `json:"id" db:"id"`
	Title       string `json:"title" db:"title"`
	Description string `json:"description" db:"description"`
	Icon        string `json:"icon" db:"icon"`
	Ord         int    `json:"ord" db:"ord"`
	IsActive    bool   `json:"is_active" db:"is_active"`
	CreatedAt   string `json:"created_at,omitempty" db:"created_at"`
}

type CourseListResponse struct {
	Total   int      `json:"total"`
	Courses []Course `json:"courses"`
}

type Section struct {
	ID          string `json:"id" db:"id"`
	CourseID    string `json:"course_id" db:"course_id"`
	Title       string `json:"title" db:"title"`
	Description string `json:"description" db:"description"`
	Tier        string `json:"tier" db:"tier"`
	Ord         int    `json:"order" db:"ord"`
	IsActive    bool   `json:"is_active" db:"is_active"`
	CreatedAt   string `json:"created_at,omitempty" db:"created_at"`
	Units       []Unit `json:"units,omitempty"`
}

type SectionListResponse struct {
	Total    int       `json:"total"`
	Sections []Section `json:"sections"`
}

type Unit struct {
	ID          string      `json:"id" db:"id"`
	SectionID   string      `json:"section_id" db:"section_id"`
	Title       string      `json:"title" db:"title"`
	Description *string     `json:"description" db:"description"`
	Ord         int         `json:"ord" db:"ord"`
	TotalLevels int         `json:"total_levels" db:"total_levels"`
	IsActive    bool        `json:"is_active" db:"is_active"`
	Levels      []LevelResp `json:"levels,omitempty"`
}

type Level struct {
	ID             string  `json:"id" db:"id"`
	UnitID         string  `json:"unit_id" db:"unit_id"`
	LevelNumber    int     `json:"level_number" db:"level_number"`
	Difficulty     string  `json:"difficulty" db:"difficulty"`
	TotalQuestions int     `json:"total_questions" db:"total_questions"`
	MinCorrect     int     `json:"min_correct" db:"min_correct"`
	XpReward       int     `json:"xp_reward" db:"xp_reward"`
	UnlockRule     *string `json:"unlock_rule,omitempty" db:"unlock_rule"`
	IsActive       bool    `json:"is_active" db:"is_active"`
}

type LevelResp struct {
	ID             string `json:"level_id"`
	UnitID         string `json:"unit_id"`
	LevelNumber    int    `json:"level_number"`
	Title          string `json:"title,omitempty"`
	Difficulty     string `json:"difficulty"`
	TotalQuestions int    `json:"total_questions"`
	MinCorrect     int    `json:"min_correct"`
	XpReward       int    `json:"xp_reward"`
	Status         string `json:"status,omitempty"`
	Score          int    `json:"score,omitempty"`
}

type Question struct {
	ID              string      `json:"id" db:"id"`
	LevelID         string      `json:"level_id" db:"level_id"`
	Type            string      `json:"type" db:"type"`
	Question        string      `json:"question" db:"question"`
	Payload         interface{} `json:"payload" db:"payload"`
	Xp              int         `json:"xp" db:"xp"`
	Ord             int         `json:"ord" db:"ord"`
	Source          string      `json:"source" db:"source"`
	DifficultyLevel int         `json:"difficulty_level" db:"difficulty_level"`
}

type UserProgress struct {
	ID             int64   `json:"id" db:"id"`
	UserID         int     `json:"user_id" db:"user_id"`
	LevelID        string  `json:"level_id" db:"level_id"`
	Status         string  `json:"status" db:"status"`
	Score          int     `json:"score" db:"score"`
	TotalQuestions int     `json:"total_questions" db:"total_questions"`
	CorrectAnswers int     `json:"correct_answers" db:"correct_answers"`
	XpEarned       int     `json:"xp_earned" db:"xp_earned"`
	TimeSpentSec   int     `json:"time_spent_seconds" db:"time_spent_seconds"`
	CompletedAt    *string `json:"completed_at,omitempty" db:"completed_at"`
}

type SubmitRequest struct {
	LevelID            string   `json:"level_id" binding:"required"`
	Score              int      `json:"score"`
	TotalQuestions     int      `json:"total_questions"`
	CorrectAnswers     int      `json:"correct_answers"`
	CorrectQuestionIDs []string `json:"correct_question_ids"`
	TimeSpentSec       int      `json:"time_spent_seconds"`
}

type AnswerItem struct {
	QuestionID string `json:"question_id"`
	Answer     string `json:"answer"`
}

type ProgressSummary struct {
	SectionID    string `json:"section_id" db:"section_id"`
	SectionTitle string `json:"section_title" db:"section_title"`
	Completed    int    `json:"completed" db:"completed"`
	Total        int    `json:"total" db:"total"`
}

type ProgressStateResponse struct {
	Success   bool              `json:"success"`
	SectionID string            `json:"section_id,omitempty"`
	Progress  map[string]string `json:"progress"`
}

type LearningPathResponse struct {
	SectionID    string            `json:"section_id"`
	SectionTitle string            `json:"section_title"`
	Units        []LearningUnit    `json:"units"`
	UserProgress map[string]string `json:"user_progress"`
}

type LearningUnit struct {
	ID          string      `json:"unit_id"`
	SectionID   string      `json:"section_id,omitempty"`
	Title       string      `json:"unit_title"`
	Ord         int         `json:"order"`
	TotalLevels int         `json:"total_levels"`
	Levels      []LevelResp `json:"levels"`
}
