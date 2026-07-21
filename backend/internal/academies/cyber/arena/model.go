// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package arena

import (
	"time"
)

type Room struct {
	ID               int64      `json:"id" db:"id"`
	Code             string     `json:"code" db:"code"`
	HostUserID       int64      `json:"host_user_id" db:"host_user_id"`
	HostName         string     `json:"host_name,omitempty" db:"host_name"`
	Title            string     `json:"title" db:"title"`
	Status           string     `json:"status" db:"status"` // waiting, playing, finished
	MaxTeams         int        `json:"max_teams" db:"max_teams"`
	PlayersPerTeam   int        `json:"players_per_team" db:"players_per_team"`
	TotalQuestions   int        `json:"total_questions" db:"total_questions"`
	QTimeSecs        int        `json:"q_time_secs" db:"q_time_secs"`
	CurrentQIndex    int        `json:"current_q_index" db:"current_q_index"`
	QStartedAt       *time.Time `json:"q_started_at" db:"q_started_at"`
	StartedAt        *time.Time `json:"started_at" db:"started_at"`
	FinishedAt       *time.Time `json:"finished_at" db:"finished_at"`
	CreatedAt        time.Time  `json:"created_at" db:"created_at"`
	BotAnswerTimestamps []byte  `json:"bot_answer_timestamps" db:"bot_answer_timestamps"`
	Teams            []Team     `json:"teams,omitempty"`
}

type Team struct {
	ID            int64     `json:"id" db:"id"`
	RoomID        int64     `json:"room_id" db:"room_id"`
	Name          string    `json:"name" db:"name"`
	Slot          int       `json:"slot" db:"slot"`
	CaptainUserID int64     `json:"captain_user_id" db:"captain_user_id"`
	CaptainName   string    `json:"captain_name,omitempty" db:"captain_name"`
	TotalScore    int       `json:"total_score" db:"total_score"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
	Players       []Player  `json:"players,omitempty"`
}

type Player struct {
	ID         int64     `json:"id" db:"id"`
	TeamID     int64     `json:"team_id" db:"team_id"`
	RoomID     int64     `json:"room_id" db:"room_id"`
	UserID     int64     `json:"user_id" db:"user_id"`
	FullName   string    `json:"full_name,omitempty" db:"full_name"`
	IsCaptain  bool      `json:"is_captain" db:"is_captain"`
	Score      int       `json:"score" db:"score"`
	CreatedAt  time.Time `json:"created_at" db:"created_at"`
}

type Question struct {
	ID            int64       `json:"id" db:"id"`
	RoomID        int64       `json:"room_id" db:"room_id"`
	QOrder        int         `json:"q_order" db:"q_order"`
	QuestionText  string      `json:"question_text" db:"question_text"`
	QuestionType  string      `json:"question_type" db:"question_type"`
	Payload       interface{} `json:"payload" db:"payload"`
	CorrectAnswer string      `json:"-" db:"correct_answer"` // Never sent to client
	Points        int         `json:"points" db:"points"`
}

type Answer struct {
	ID           int64     `json:"id" db:"id"`
	RoomID       int64     `json:"room_id" db:"room_id"`
	QuestionID   int64     `json:"question_id" db:"question_id"`
	TeamID       int64     `json:"team_id" db:"team_id"`
	PlayerID     int64     `json:"player_id" db:"player_id"`
	Answer       string    `json:"answer" db:"answer"`
	IsCorrect    bool      `json:"is_correct" db:"is_correct"`
	TimeTakenMs  int       `json:"time_taken_ms" db:"time_taken_ms"`
	PointsEarned int       `json:"points_earned" db:"points_earned"`
	AnsweredAt   time.Time `json:"answered_at" db:"answered_at"`
}

// Request & Response structs

type CreateTeamRequest struct {
	Name string `json:"name" binding:"required"`
}

type AnswerRequest struct {
	Answer string `json:"answer" binding:"required"`
}

// State response for polling
type RoomState struct {
	Status           string             `json:"status"`
	CurrentQuestion  *QuestionState     `json:"question,omitempty"`
	Leaderboard      []TeamScore        `json:"leaderboard,omitempty"`
	MyTeamScore      int                `json:"my_team_score,omitempty"`
	AlreadyAnswered  bool               `json:"already_answered"`
}

type QuestionState struct {
	Index             int         `json:"index"`
	Total             int         `json:"total"`
	Text              string      `json:"text"`
	Type              string      `json:"type"`
	Payload           interface{} `json:"payload"`
	TimeRemainingSecs int         `json:"time_remaining_secs"`
}

type TeamScore struct {
	TeamName string `json:"team_name"`
	Score    int    `json:"score"`
}
