// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package arena

import (
	"database/sql"
	"encoding/json"
	"fmt"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

// scanJSON helper
func scanJSON(dest interface{}, src interface{}) error {
	switch s := src.(type) {
	case []byte:
		return json.Unmarshal(s, dest)
	case string:
		return json.Unmarshal([]byte(s), dest)
	default:
		return fmt.Errorf("unexpected type %T for JSON", src)
	}
}

func (r *Repository) CreateRoom(room *Room) error {
	return r.db.QueryRowx(`
		INSERT INTO arena_rooms (code, host_user_id, title, max_teams, players_per_team, total_questions, q_time_secs)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, status, current_q_index, created_at
	`, room.Code, room.HostUserID, room.Title, room.MaxTeams, room.PlayersPerTeam, room.TotalQuestions, room.QTimeSecs).
		Scan(&room.ID, &room.Status, &room.CurrentQIndex, &room.CreatedAt)
}

func (r *Repository) GetRoomByCode(code string) (*Room, error) {
	var room Room
	err := r.db.Get(&room, `
		SELECT r.*, COALESCE(u.full_name, u.email) as host_name 
		FROM arena_rooms r
		JOIN users u ON r.host_user_id = u.id
		WHERE r.code = $1
	`, code)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get room: %w", err)
	}
	return &room, nil
}

func (r *Repository) UpdateRoomState(room *Room) error {
	_, err := r.db.Exec(`
		UPDATE arena_rooms 
		SET status = $1, current_q_index = $2, q_started_at = $3, started_at = $4, finished_at = $5
		WHERE id = $6
	`, room.Status, room.CurrentQIndex, room.QStartedAt, room.StartedAt, room.FinishedAt, room.ID)
	return err
}

func (r *Repository) DeleteRoom(id int64) error {
	_, err := r.db.Exec("DELETE FROM arena_rooms WHERE id = $1", id)
	return err
}

func (r *Repository) GetWaitingRooms(limit int) ([]Room, error) {
	var rooms []Room
	err := r.db.Select(&rooms, `
		SELECT r.*, COALESCE(u.full_name, u.email) as host_name 
		FROM arena_rooms r
		JOIN users u ON r.host_user_id = u.id
		WHERE r.status = 'waiting'
		ORDER BY r.created_at DESC
		LIMIT $1
	`, limit)
	if err != nil {
		return nil, fmt.Errorf("get waiting rooms: %w", err)
	}
	return rooms, nil
}

func (r *Repository) CreateTeam(team *Team) error {
	return r.db.QueryRowx(`
		INSERT INTO arena_teams (room_id, name, slot, captain_user_id)
		VALUES ($1, $2, $3, $4)
		RETURNING id, total_score, created_at
	`, team.RoomID, team.Name, team.Slot, team.CaptainUserID).
		Scan(&team.ID, &team.TotalScore, &team.CreatedAt)
}

func (r *Repository) GetTeamsByRoomID(roomID int64) ([]Team, error) {
	var teams []Team
	err := r.db.Select(&teams, `
		SELECT t.*, COALESCE(u.full_name, u.email) as captain_name
		FROM arena_teams t
		JOIN users u ON t.captain_user_id = u.id
		WHERE t.room_id = $1
		ORDER BY t.slot ASC
	`, roomID)
	if err != nil {
		return nil, fmt.Errorf("get teams: %w", err)
	}
	return teams, nil
}

func (r *Repository) AddPlayerToTeam(player *Player) error {
	return r.db.QueryRowx(`
		INSERT INTO arena_players (team_id, room_id, user_id, is_captain)
		VALUES ($1, $2, $3, $4)
		RETURNING id, score, created_at
	`, player.TeamID, player.RoomID, player.UserID, player.IsCaptain).
		Scan(&player.ID, &player.Score, &player.CreatedAt)
}

func (r *Repository) GetPlayersByRoomID(roomID int64) ([]Player, error) {
	var players []Player
	err := r.db.Select(&players, `
		SELECT p.*, COALESCE(u.full_name, u.email) as full_name
		FROM arena_players p
		JOIN users u ON p.user_id = u.id
		WHERE p.room_id = $1
		ORDER BY p.score DESC
	`, roomID)
	if err != nil {
		return nil, fmt.Errorf("get players: %w", err)
	}
	return players, nil
}

func (r *Repository) GetPlayerInRoom(roomID, userID int64) (*Player, error) {
	var p Player
	err := r.db.Get(&p, `
		SELECT p.*, COALESCE(u.full_name, u.email) as full_name
		FROM arena_players p
		JOIN users u ON p.user_id = u.id
		WHERE p.room_id = $1 AND p.user_id = $2
	`, roomID, userID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get player: %w", err)
	}
	return &p, nil
}

func (r *Repository) InsertQuestions(questions []Question) error {
	for i := range questions {
		q := &questions[i]
		payloadBytes, _ := json.Marshal(q.Payload)
		err := r.db.QueryRowx(`
			INSERT INTO arena_questions (room_id, q_order, question_text, question_type, payload, correct_answer, points)
			VALUES ($1, $2, $3, $4, $5, $6, $7)
			RETURNING id
		`, q.RoomID, q.QOrder, q.QuestionText, q.QuestionType, payloadBytes, q.CorrectAnswer, q.Points).Scan(&q.ID)
		if err != nil {
			return fmt.Errorf("insert question: %w", err)
		}
	}
	return nil
}

func (r *Repository) GetQuestionByOrder(roomID int64, qOrder int) (*Question, error) {
	var q Question
	var payloadRaw interface{}
	err := r.db.QueryRowx(`
		SELECT id, room_id, q_order, question_text, question_type, payload, correct_answer, points
		FROM arena_questions
		WHERE room_id = $1 AND q_order = $2
	`, roomID, qOrder).Scan(&q.ID, &q.RoomID, &q.QOrder, &q.QuestionText, &q.QuestionType, &payloadRaw, &q.CorrectAnswer, &q.Points)
	
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get question: %w", err)
	}
	if err := scanJSON(&q.Payload, payloadRaw); err != nil {
		return nil, err
	}
	return &q, nil
}

func (r *Repository) SaveAnswer(ans *Answer) error {
	return r.db.QueryRowx(`
		INSERT INTO arena_answers (room_id, question_id, team_id, player_id, answer, is_correct, time_taken_ms, points_earned)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, answered_at
	`, ans.RoomID, ans.QuestionID, ans.TeamID, ans.PlayerID, ans.Answer, ans.IsCorrect, ans.TimeTakenMs, ans.PointsEarned).
		Scan(&ans.ID, &ans.AnsweredAt)
}

func (r *Repository) HasAnswered(questionID, playerID int64) (bool, error) {
	var count int
	err := r.db.Get(&count, "SELECT count(*) FROM arena_answers WHERE question_id = $1 AND player_id = $2", questionID, playerID)
	return count > 0, err
}

func (r *Repository) UpdateScores(teamID, playerID int64, points int) error {
	tx, err := r.db.Beginx()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	_, err = tx.Exec("UPDATE arena_players SET score = score + $1 WHERE id = $2", points, playerID)
	if err != nil {
		return err
	}

	_, err = tx.Exec("UPDATE arena_teams SET total_score = total_score + $1 WHERE id = $2", points, teamID)
	if err != nil {
		return err
	}

	return tx.Commit()
}
