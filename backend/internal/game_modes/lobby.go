package game_modes

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"

	"github.com/jmoiron/sqlx"
)

var ModeCards = []ModeCard{
	{
		Mode:        "2v2",
		Title:       "2 vs 2 — Attacker & Defender",
		Description: "4 pemain asli. 1 tim = 1 Attacker + 1 Defender. Bertanding dalam simulasi keamanan siber.",
		Icon:        "people",
		MinPlayers:  4,
		MaxPlayers:  4,
	},
	{
		Mode:        "1v1_ai",
		Title:       "1 vs 1 — Latihan dengan AI",
		Description: "Hadapi AI yang menyesuaikan kesulitan berdasarkan XP akumulasi pemain. Kamu memegang semua peran.",
		Icon:        "robot",
		MinPlayers:  1,
		MaxPlayers:  1,
	},
}

type LobbyService struct {
	db *sqlx.DB
}

func NewLobbyService(db *sqlx.DB) *LobbyService {
	return &LobbyService{db: db}
}

func (s *LobbyService) CreateLobby(hostID int64) (*GameRoom, error) {
	code, err := generateRoomCode()
	if err != nil {
		return nil, err
	}

	room := &GameRoom{}
	err = s.db.QueryRowx(`
		INSERT INTO game_rooms (code, host_user_id, status, player_count)
		VALUES ($1, $2, 'lobby', 1)
		RETURNING id, code, host_user_id, mode, status,
		          team_a_attacker, team_a_defender,
		          team_b_attacker, team_b_defender,
		          player_count, current_round, max_rounds,
		          created_at, started_at, finished_at
	`, code, hostID).StructScan(room)
	if err != nil {
		return nil, fmt.Errorf("create lobby: %w", err)
	}

	return room, nil
}

func (s *LobbyService) JoinLobby(code string, userID int64) (*GameRoom, error) {
	var room GameRoom
	err := s.db.QueryRowx(`SELECT * FROM game_rooms WHERE code = $1 AND status = 'lobby'`, code).
		StructScan(&room)
	if err != nil {
		return nil, fmt.Errorf("lobby not found or already started: %w", err)
	}
	if room.PlayerCount >= 4 {
		return nil, fmt.Errorf("lobby is full")
	}

	_, err = s.db.Exec(`
		UPDATE game_rooms SET player_count = player_count + 1 WHERE id = $1`, room.ID)
	if err != nil {
		return nil, fmt.Errorf("join lobby: %w", err)
	}

	room.PlayerCount++
	return &room, nil
}

func (s *LobbyService) GetLobby(code string) (*GameRoom, []RoomPlayer, error) {
	var room GameRoom
	err := s.db.QueryRowx(`SELECT * FROM game_rooms WHERE code = $1`, code).StructScan(&room)
	if err != nil {
		return nil, nil, fmt.Errorf("room not found: %w", err)
	}

	players := []RoomPlayer{}
	return &room, players, nil
}

func (s *LobbyService) SelectMode(code, mode string) error {
	valid := false
	for _, m := range ModeCards {
		if m.Mode == mode {
			valid = true
			break
		}
	}
	if !valid {
		return fmt.Errorf("invalid mode: %s", mode)
	}

	_, err := s.db.Exec(`UPDATE game_rooms SET mode = $1 WHERE code = $2`, mode, code)
	return err
}

func (s *LobbyService) StartGame(code string) (*GameRoom, error) {
	var room GameRoom
	err := s.db.QueryRowx(`SELECT * FROM game_rooms WHERE code = $1 AND status = 'lobby'`, code).
		StructScan(&room)
	if err != nil {
		return nil, fmt.Errorf("room not found: %w", err)
	}
	if room.Mode == "" {
		return nil, fmt.Errorf("mode not selected yet")
	}

	_, err = s.db.Exec(`
		UPDATE game_rooms SET status = 'playing', started_at = NOW()
		WHERE id = $1`, room.ID)
	if err != nil {
		return nil, fmt.Errorf("start game: %w", err)
	}

	room.Status = "playing"
	return &room, nil
}

func generateRoomCode() (string, error) {
	b := make([]byte, 3)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b)[:6], nil
}
