package game_modes

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	"github.com/pradigi/backend/internal/ai_agent"
)

type GameService struct {
	db    *sqlx.DB
	agent *ai_agent.Agent
}

func NewGameService(db *sqlx.DB, agent *ai_agent.Agent) *GameService {
	return &GameService{db: db, agent: agent}
}

func (s *GameService) generateScenario2v2(ctx context.Context, room *GameRoom, roundNum int, attackerTeam int) (string, error) {
	avgXP := s.getTeamAverageXP(room, attackerTeam)

	userContext := fmt.Sprintf(
		`Kamu adalah wasit untuk game 2v2 keamanan siber. 
Round %d, Tim %d menyerang.
Rata-rata XP pemain di tim ini: %d.
Buat satu skenario serangan siber yang realistis untuk dihadapi defender lawan.
Skenario harus sesuai level XP pemain.
Keluarkan PradigiResponse JSON dengan dialog_ai berisi skenario dan docker_eval_command berisi perintah untuk defender.`,
		roundNum, attackerTeam, avgXP,
	)

	resp, _, err := s.agent.Execute(userContext, nil)
	if err != nil {
		return "", err
	}
	return resp.DialogAI, nil
}

func (s *GameService) evaluateAction2v2(ctx context.Context, room *GameRoom, roundNum int, role string, input string) (*ai_agent.PradigiResponse, error) {
	resp, _, err := s.agent.Execute(
		fmt.Sprintf(`Evaluasi aksi player berikut:
Role: %s
Input: %s
Round: %d

Beri nilai computational_score_change dan ethical_score_change.`, role, input, roundNum),
		nil,
	)
	return resp, err
}

func (s *GameService) generateScenario1v1AI(ctx context.Context, room *GameRoom, roundNum int) (string, error) {
	allXP := s.getRoomTotalXP(room)

	userContext := fmt.Sprintf(
		`Kamu adalah AI lawan untuk mode latihan 1v1.
Total XP akumulasi pemain: %d.
Buat skenario serangan siber yang menantang sesuai level XP tersebut.
Keluarkan PradigiResponse JSON dengan dialog_ai berisi skenario serangan.`,
		allXP,
	)

	resp, _, err := s.agent.Execute(userContext, nil)
	if err != nil {
		return "", err
	}
	return resp.DialogAI, nil
}

func (s *GameService) CreateRound(roomID int64, roundNum int, attackerTeam int, scenario string) (*GameRound, error) {
	round := &GameRound{}
	err := s.db.QueryRowx(`
		INSERT INTO game_rounds (room_id, round_num, attacker_team, scenario, status)
		VALUES ($1, $2, $3, $4, 'active')
		RETURNING id, room_id, round_num, attacker_team, scenario, status, created_at
	`, roomID, roundNum, attackerTeam, scenario).StructScan(round)
	return round, err
}

func (s *GameService) SubmitAction(roomCode string, userID int64, input string) (*GameAction, *GameRound, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	var room GameRoom
	err := s.db.QueryRowx(`SELECT * FROM game_rooms WHERE code = $1 AND status = 'playing'`, roomCode).
		StructScan(&room)
	if err != nil {
		return nil, nil, fmt.Errorf("active room not found: %w", err)
	}

	var round GameRound
	err = s.db.QueryRowx(`
		SELECT * FROM game_rounds
		WHERE room_id = $1 AND round_num = $2 AND status = 'active'
		ORDER BY id DESC LIMIT 1
	`, room.ID, room.CurrentRound).StructScan(&round)
	if err != nil {
		return nil, nil, fmt.Errorf("no active round: %w", err)
	}

	role := s.detectRole(&room, userID)

	var pradigiResp *ai_agent.PradigiResponse
	if room.Mode == "2v2" {
		pradigiResp, err = s.evaluateAction2v2(ctx, &room, round.RoundNum, role, input)
	} else {
		pradigiResp, err = s.evaluateAction2v2(ctx, &room, round.RoundNum, role, input)
	}
	if err != nil {
		return nil, nil, fmt.Errorf("AI evaluation: %w", err)
	}

	action := &GameAction{}
	err = s.db.QueryRowx(`
		INSERT INTO game_actions (round_id, user_id, role, input, output, score_change, ethical_change)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, round_id, user_id, role, input, output, score_change, ethical_change, time_taken_secs, created_at
	`, round.ID, userID, role, input, pradigiResp.DialogAI,
		pradigiResp.ComputationalScoreChange, pradigiResp.EthicalScoreChange).StructScan(action)
	if err != nil {
		return nil, nil, fmt.Errorf("save action: %w", err)
	}

	return action, &round, nil
}

func (s *GameService) GetGameState(roomCode string, userID int64) (*GameStateResponse, error) {
	var room GameRoom
	err := s.db.QueryRowx(`SELECT * FROM game_rooms WHERE code = $1`, roomCode).StructScan(&room)
	if err != nil {
		return nil, fmt.Errorf("room not found: %w", err)
	}

	var round *GameRound
	if room.Status == "playing" {
		r := &GameRound{}
		err = s.db.QueryRowx(`
			SELECT * FROM game_rounds
			WHERE room_id = $1 AND round_num = $2
			LIMIT 1
		`, room.ID, room.CurrentRound).StructScan(r)
		if err == nil {
			round = r
		}
	}

	var actions []GameAction
	err = s.db.Select(&actions, `
		SELECT * FROM game_actions
		WHERE round_id IN (SELECT id FROM game_rounds WHERE room_id = $1)
		ORDER BY created_at DESC
	`, room.ID)

	var myScore int
	s.db.Get(&myScore, `SELECT COALESCE(SUM(score_change), 0) FROM game_actions WHERE user_id = $1`, userID)

	teamAScore := s.getTeamScore(room.ID, 1)
	teamBScore := s.getTeamScore(room.ID, 2)

	resp := &GameStateResponse{
		Room:       room,
		Round:      round,
		Actions:    actions,
		MyScore:    myScore,
		TeamAScore: teamAScore,
		TeamBScore: teamBScore,
	}

	return resp, nil
}

func (s *GameService) detectRole(room *GameRoom, userID int64) string {
	if room.TeamAAttacker != nil && *room.TeamAAttacker == userID {
		return "attacker"
	}
	if room.TeamADefender != nil && *room.TeamADefender == userID {
		return "defender"
	}
	if room.TeamBAttacker != nil && *room.TeamBAttacker == userID {
		return "attacker"
	}
	if room.TeamBDefender != nil && *room.TeamBDefender == userID {
		return "defender"
	}
	return "player"
}

func (s *GameService) getTeamAverageXP(room *GameRoom, team int) int {
	ids := []int64{}
	if team == 1 {
		if room.TeamAAttacker != nil {
			ids = append(ids, *room.TeamAAttacker)
		}
		if room.TeamADefender != nil {
			ids = append(ids, *room.TeamADefender)
		}
	} else {
		if room.TeamBAttacker != nil {
			ids = append(ids, *room.TeamBAttacker)
		}
		if room.TeamBDefender != nil {
			ids = append(ids, *room.TeamBDefender)
		}
	}
	if len(ids) == 0 {
		return 0
	}
	var totalXP int
	idsJSON, _ := json.Marshal(ids)
	s.db.Get(&totalXP, `SELECT COALESCE(SUM(total_xp), 0) FROM users WHERE id = ANY($1)`, string(idsJSON))
	return totalXP / len(ids)
}

func (s *GameService) getRoomTotalXP(room *GameRoom) int {
	ids := []int64{}
	if room.TeamAAttacker != nil {
		ids = append(ids, *room.TeamAAttacker)
	}
	if room.TeamADefender != nil {
		ids = append(ids, *room.TeamADefender)
	}
	if room.TeamBAttacker != nil {
		ids = append(ids, *room.TeamBAttacker)
	}
	if room.TeamBDefender != nil {
		ids = append(ids, *room.TeamBDefender)
	}

	if len(ids) == 0 {
		return 0
	}
	var totalXP int
	idsJSON, _ := json.Marshal(ids)
	s.db.Get(&totalXP, `SELECT COALESCE(SUM(total_xp), 0) FROM users WHERE id = ANY($1)`, string(idsJSON))
	return totalXP
}

func (s *GameService) getTeamScore(roomID int64, team int) int {
	var score int
	slot := team
	err := s.db.Get(&score, `
		SELECT COALESCE(SUM(ga.score_change), 0)
		FROM game_actions ga
		JOIN game_rounds gr ON ga.round_id = gr.id
		WHERE gr.room_id = $1 AND gr.attacker_team = $2
	`, roomID, slot)
	if err != nil {
		return 0
	}
	return score
}

func (s *GameService) SaveTeamAssignment(code string, teamAAttacker, teamADefender, teamBAttacker, teamBDefender *int64) error {
	_, err := s.db.Exec(`
		UPDATE game_rooms SET
			team_a_attacker = $2, team_a_defender = $3,
			team_b_attacker = $4, team_b_defender = $5
		WHERE code = $1
	`, code, teamAAttacker, teamADefender, teamBAttacker, teamBDefender)
	return err
}

var _ = sql.ErrNoRows
