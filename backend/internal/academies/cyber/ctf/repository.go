package ctf

import (
	"context"
	"database/sql"
	"errors"

	"github.com/jmoiron/sqlx"
)

type CTFRepository interface {
	CreateCTFRoom(ctx context.Context, roomID int64, defenseDur, attackDur int) (*CTFRoom, error)
	GetCTFRoom(ctx context.Context, roomID int64) (*CTFRoom, error)
	UpdatePhase(ctx context.Context, ctfRoomID int64, phase string) error
	GetCTFTeam(ctx context.Context, ctfRoomID, teamID int64) (*CTFTeam, error)
	GetAllCTFTeams(ctx context.Context, ctfRoomID int64) ([]*CTFTeam, error)
	SaveDefense(ctx context.Context, ctfRoomID, teamID int64, flag, imageURL, method, key string) error
	SaveAttackLog(ctx context.Context, log *CTFAttackLog) error
	GetAttackLogs(ctx context.Context, ctfRoomID, teamID int64) ([]*CTFAttackLog, error)
	MarkFlagFound(ctx context.Context, ctfRoomID, foundByTeamID, defenderTeamID int64) error
	CreatePatchChallenge(ctx context.Context, challenge *CTFPatchChallenge) (*CTFPatchChallenge, error)
	GetActivePatchChallenge(ctx context.Context, ctfRoomID, teamID int64) (*CTFPatchChallenge, error)
	SubmitPatchAnswer(ctx context.Context, challengeID int64, answer string, timeTaken int) error
	UpdateTeamScore(ctx context.Context, ctfRoomID, teamID int64, score int) error
	GetFinalScores(ctx context.Context, ctfRoomID int64) ([]*CTFTeam, error)
}

type PostgresCTFRepository struct {
	db *sqlx.DB
}

func NewPostgresCTFRepository(db *sqlx.DB) *PostgresCTFRepository {
	return &PostgresCTFRepository{db: db}
}

func (r *PostgresCTFRepository) CreateCTFRoom(ctx context.Context, roomID int64, defenseDur, attackDur int) (*CTFRoom, error) {
	query := `
		INSERT INTO ctf_rooms (room_id, defense_duration_sec, attack_duration_sec)
		VALUES ($1, $2, $3)
		RETURNING *
	`
	var room CTFRoom
	err := r.db.GetContext(ctx, &room, query, roomID, defenseDur, attackDur)
	return &room, err
}

func (r *PostgresCTFRepository) GetCTFRoom(ctx context.Context, roomID int64) (*CTFRoom, error) {
	var room CTFRoom
	err := r.db.GetContext(ctx, &room, "SELECT * FROM ctf_rooms WHERE id = $1 OR room_id = $1 ORDER BY id DESC LIMIT 1", roomID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &room, nil
}

func (r *PostgresCTFRepository) UpdatePhase(ctx context.Context, ctfRoomID int64, phase string) error {
	query := `
		UPDATE ctf_rooms 
		SET phase = $2, phase_started_at = NOW(), updated_at = NOW()
		WHERE id = $1
	`
	_, err := r.db.ExecContext(ctx, query, ctfRoomID, phase)
	return err
}

func (r *PostgresCTFRepository) GetCTFTeam(ctx context.Context, ctfRoomID, teamID int64) (*CTFTeam, error) {
	var team CTFTeam
	err := r.db.GetContext(ctx, &team, "SELECT * FROM ctf_teams WHERE ctf_room_id = $1 AND team_id = $2", ctfRoomID, teamID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &team, nil
}

func (r *PostgresCTFRepository) GetAllCTFTeams(ctx context.Context, ctfRoomID int64) ([]*CTFTeam, error) {
	var teams []*CTFTeam
	err := r.db.SelectContext(ctx, &teams, "SELECT * FROM ctf_teams WHERE ctf_room_id = $1", ctfRoomID)
	return teams, err
}

func (r *PostgresCTFRepository) SaveDefense(ctx context.Context, ctfRoomID, teamID int64, flag, imageURL, method, key string) error {
	query := `
		INSERT INTO ctf_teams (ctf_room_id, team_id, flag, defense_image_url, cipher_method, cipher_key)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (ctf_room_id, team_id) DO UPDATE SET
			flag = EXCLUDED.flag,
			defense_image_url = EXCLUDED.defense_image_url,
			cipher_method = EXCLUDED.cipher_method,
			cipher_key = EXCLUDED.cipher_key
	`
	_, err := r.db.ExecContext(ctx, query, ctfRoomID, teamID, flag, imageURL, method, key)
	return err
}

func (r *PostgresCTFRepository) SaveAttackLog(ctx context.Context, log *CTFAttackLog) error {
	query := `
		INSERT INTO ctf_attack_logs (ctf_room_id, attacking_team_id, user_id, prompt, ai_response, tokens_used)
		VALUES (:ctf_room_id, :attacking_team_id, :user_id, :prompt, :ai_response, :tokens_used)
		RETURNING id, created_at
	`
	stmt, err := r.db.PrepareNamedContext(ctx, query)
	if err != nil {
		return err
	}
	defer stmt.Close()
	return stmt.GetContext(ctx, log, log)
}

func (r *PostgresCTFRepository) GetAttackLogs(ctx context.Context, ctfRoomID, teamID int64) ([]*CTFAttackLog, error) {
	var logs []*CTFAttackLog
	err := r.db.SelectContext(ctx, &logs, "SELECT * FROM ctf_attack_logs WHERE ctf_room_id = $1 AND attacking_team_id = $2 ORDER BY created_at ASC", ctfRoomID, teamID)
	return logs, err
}

func (r *PostgresCTFRepository) MarkFlagFound(ctx context.Context, ctfRoomID, foundByTeamID, defenderTeamID int64) error {
	query := `
		UPDATE ctf_teams
		SET flag_found = TRUE, flag_found_at = NOW(), flag_found_by = $3
		WHERE ctf_room_id = $1 AND team_id = $2
	`
	_, err := r.db.ExecContext(ctx, query, ctfRoomID, defenderTeamID, foundByTeamID)
	return err
}

func (r *PostgresCTFRepository) CreatePatchChallenge(ctx context.Context, challenge *CTFPatchChallenge) (*CTFPatchChallenge, error) {
	query := `
		INSERT INTO ctf_patch_challenges (ctf_room_id, team_id, challenge_type, difficulty, question, correct_answer)
		VALUES (:ctf_room_id, :team_id, :challenge_type, :difficulty, :question, :correct_answer)
		RETURNING *
	`
	stmt, err := r.db.PrepareNamedContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer stmt.Close()
	var newChallenge CTFPatchChallenge
	err = stmt.GetContext(ctx, &newChallenge, challenge)
	return &newChallenge, err
}

func (r *PostgresCTFRepository) GetActivePatchChallenge(ctx context.Context, ctfRoomID, teamID int64) (*CTFPatchChallenge, error) {
	var challenge CTFPatchChallenge
	err := r.db.GetContext(ctx, &challenge, "SELECT * FROM ctf_patch_challenges WHERE ctf_room_id = $1 AND team_id = $2 AND solved = FALSE ORDER BY created_at DESC LIMIT 1", ctfRoomID, teamID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &challenge, nil
}

func (r *PostgresCTFRepository) SubmitPatchAnswer(ctx context.Context, challengeID int64, answer string, timeTaken int) error {
	query := `
		UPDATE ctf_patch_challenges
		SET user_answer = $2, time_taken_sec = $3, solved = TRUE, solved_at = NOW()
		WHERE id = $1
	`
	_, err := r.db.ExecContext(ctx, query, challengeID, answer, timeTaken)
	if err != nil {
		return err
	}

	// Also update team patch status
	teamQuery := `
		UPDATE ctf_teams
		SET patch_completed = TRUE, patch_time_sec = $3
		WHERE id = (SELECT team_id FROM ctf_patch_challenges WHERE id = $1)
	`
	_, _ = r.db.ExecContext(ctx, teamQuery, challengeID, answer, timeTaken)
	
	return nil
}

func (r *PostgresCTFRepository) UpdateTeamScore(ctx context.Context, ctfRoomID, teamID int64, score int) error {
	query := `
		UPDATE ctf_teams
		SET score = score + $3
		WHERE ctf_room_id = $1 AND team_id = $2
	`
	_, err := r.db.ExecContext(ctx, query, ctfRoomID, teamID, score)
	return err
}

func (r *PostgresCTFRepository) GetFinalScores(ctx context.Context, ctfRoomID int64) ([]*CTFTeam, error) {
	var teams []*CTFTeam
	err := r.db.SelectContext(ctx, &teams, "SELECT * FROM ctf_teams WHERE ctf_room_id = $1 ORDER BY score DESC", ctfRoomID)
	return teams, err
}
