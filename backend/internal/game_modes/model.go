package game_modes

import "time"

type ModeCard struct {
	Mode        string `json:"mode"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Icon        string `json:"icon"`
	MinPlayers  int    `json:"min_players"`
	MaxPlayers  int    `json:"max_players"`
}

type GameRoom struct {
	ID            int64        `json:"id" db:"id"`
	Code          string       `json:"code" db:"code"`
	HostUserID    int64        `json:"host_user_id" db:"host_user_id"`
	Mode          string       `json:"mode" db:"mode"`
	Status        string       `json:"status" db:"status"`
	TeamAAttacker *int64       `json:"team_a_attacker" db:"team_a_attacker"`
	TeamADefender *int64       `json:"team_a_defender" db:"team_a_defender"`
	TeamBAttacker *int64       `json:"team_b_attacker" db:"team_b_attacker"`
	TeamBDefender *int64       `json:"team_b_defender" db:"team_b_defender"`
	PlayerCount   int          `json:"player_count" db:"player_count"`
	CurrentRound  int          `json:"current_round" db:"current_round"`
	MaxRounds     int          `json:"max_rounds" db:"max_rounds"`
	CreatedAt     time.Time    `json:"created_at" db:"created_at"`
	StartedAt     *time.Time   `json:"started_at" db:"started_at"`
	FinishedAt    *time.Time   `json:"finished_at" db:"finished_at"`
	Players       []RoomPlayer `json:"players,omitempty"`
}

type RoomPlayer struct {
	UserID   int64  `json:"user_id"`
	FullName string `json:"full_name"`
	Role     string `json:"role"`
	Team     int    `json:"team"`
	TotalXP  int    `json:"total_xp"`
}

type GameRound struct {
	ID           int64     `json:"id" db:"id"`
	RoomID       int64     `json:"room_id" db:"room_id"`
	RoundNum     int       `json:"round_num" db:"round_num"`
	AttackerTeam int       `json:"attacker_team" db:"attacker_team"`
	Scenario     string    `json:"scenario" db:"scenario"`
	Status       string    `json:"status" db:"status"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
}

type GameAction struct {
	ID            int64     `json:"id" db:"id"`
	RoundID       int64     `json:"round_id" db:"round_id"`
	UserID        int64     `json:"user_id" db:"user_id"`
	Role          string    `json:"role" db:"role"`
	Input         string    `json:"input" db:"input"`
	Output        string    `json:"output" db:"output"`
	ScoreChange   int       `json:"score_change" db:"score_change"`
	EthicalChange int       `json:"ethical_change" db:"ethical_change"`
	TimeTakenSecs int       `json:"time_taken_secs" db:"time_taken_secs"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
}

type CreateLobbyRequest struct {
	UserID int64 `json:"user_id"`
}

type CreateLobbyResponse struct {
	Code string `json:"code"`
}

type JoinLobbyRequest struct {
	Code   string `json:"code"`
	UserID int64  `json:"user_id"`
}

type SelectModeRequest struct {
	Code string `json:"code"`
	Mode string `json:"mode"`
}

type StartGameRequest struct {
	Code string `json:"code"`
}

type LobbyStateResponse struct {
	Room    GameRoom     `json:"room"`
	Modes   []ModeCard   `json:"modes"`
	Players []RoomPlayer `json:"players"`
}

type SubmitActionRequest struct {
	Code  string `json:"code"`
	Input string `json:"input"`
}

type GameStateResponse struct {
	Room       GameRoom     `json:"room"`
	Round      *GameRound   `json:"round,omitempty"`
	Actions    []GameAction `json:"actions"`
	MyScore    int          `json:"my_score"`
	TeamAScore int          `json:"team_a_score"`
	TeamBScore int          `json:"team_b_score"`
}
