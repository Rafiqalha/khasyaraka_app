package cyber

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

func (r *Repository) GetModulesWithCounts() ([]ModuleBrief, error) {
	var modules []ModuleBrief
	err := r.db.Select(&modules, `
		SELECT m.id, m.title, m.difficulty,
			(SELECT COUNT(*) FROM cyber_challenges c WHERE c.module_id = m.id) AS challenges,
			0 AS solved
		FROM cyber_modules m ORDER BY m.difficulty`)
	if err != nil {
		return nil, fmt.Errorf("get modules: %w", err)
	}
	return modules, nil
}

func (r *Repository) GetModuleSolvedCounts(userID int64) (map[string]int, error) {
	rows, err := r.db.Queryx(`
		SELECT c.module_id, COUNT(*) AS solved
		FROM user_solved_challenges us
		JOIN cyber_challenges c ON c.id = us.challenge_id
		WHERE us.user_id = $1
		GROUP BY c.module_id`, userID)
	if err != nil {
		return nil, fmt.Errorf("get solved counts: %w", err)
	}
	defer rows.Close()

	counts := make(map[string]int)
	for rows.Next() {
		var moduleID string
		var count int
		if err := rows.Scan(&moduleID, &count); err != nil {
			return nil, err
		}
		counts[moduleID] = count
	}
	return counts, nil
}

func (r *Repository) GetModuleByID(id string) (*Module, error) {
	var m Module
	row := r.db.QueryRowx("SELECT id, title, original_title, difficulty, min_read_seconds, intel_content FROM cyber_modules WHERE id = $1", id)
	var intelRaw interface{}
	err := row.Scan(&m.ID, &m.Title, &m.OriginalTitle, &m.Difficulty, &m.MinReadSeconds, &intelRaw)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get module: %w", err)
	}
	if err := scanJSON(&m.IntelContent, intelRaw); err != nil {
		return nil, err
	}
	return &m, nil
}

func (r *Repository) GetChallengesByModule(moduleID string) ([]Challenge, error) {
	rows, err := r.db.Queryx("SELECT id, module_id, level, category, difficulty, encrypted_data, decrypted_answer, xp_reward FROM cyber_challenges WHERE module_id = $1 ORDER BY level", moduleID)
	if err != nil {
		return nil, fmt.Errorf("get challenges: %w", err)
	}
	defer rows.Close()

	var challenges []Challenge
	for rows.Next() {
		var c Challenge
		var encRaw interface{}
		err := rows.Scan(&c.ID, &c.ModuleID, &c.Level, &c.Category, &c.Difficulty, &encRaw, &c.DecryptedAnswer, &c.XpReward)
		if err != nil {
			return nil, fmt.Errorf("scan challenge: %w", err)
		}
		if err := scanJSON(&c.EncryptedData, encRaw); err != nil {
			return nil, err
		}
		challenges = append(challenges, c)
	}
	return challenges, nil
}

func (r *Repository) GetChallengeByID(id string) (*Challenge, error) {
	var c Challenge
	var encRaw interface{}
	err := r.db.QueryRowx("SELECT id, module_id, level, category, difficulty, encrypted_data, decrypted_answer, xp_reward FROM cyber_challenges WHERE id = $1", id).Scan(
		&c.ID, &c.ModuleID, &c.Level, &c.Category, &c.Difficulty, &encRaw, &c.DecryptedAnswer, &c.XpReward,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get challenge: %w", err)
	}
	if err := scanJSON(&c.EncryptedData, encRaw); err != nil {
		return nil, err
	}
	return &c, nil
}

func (r *Repository) GetSolvedChallengeIDs(userID int64) (map[string]bool, error) {
	rows, err := r.db.Queryx("SELECT challenge_id FROM user_solved_challenges WHERE user_id = $1", userID)
	if err != nil {
		return nil, fmt.Errorf("get solved: %w", err)
	}
	defer rows.Close()

	solved := make(map[string]bool)
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, fmt.Errorf("scan solved: %w", err)
		}
		solved[id] = true
	}
	return solved, nil
}

func (r *Repository) IsChallengeSolved(userID int64, challengeID string) (bool, error) {
	var count int
	err := r.db.Get(&count, "SELECT COUNT(*) FROM user_solved_challenges WHERE user_id = $1 AND challenge_id = $2", userID, challengeID)
	if err != nil {
		return false, fmt.Errorf("check solved: %w", err)
	}
	return count > 0, nil
}

func (r *Repository) MarkSolved(userID int64, challengeID string) error {
	_, err := r.db.Exec("INSERT INTO user_solved_challenges (user_id, challenge_id) VALUES ($1, $2) ON CONFLICT DO NOTHING", userID, challengeID)
	return err
}

func (r *Repository) UpsertLevelProgress(userID int64, moduleID string, level int, xp int) error {
	_, err := r.db.Exec(`
		INSERT INTO cyber_level_progress (user_id, module_id, level, stars, score, is_completed)
		VALUES ($1, $2, $3, 1, $4, TRUE)
		ON CONFLICT (user_id, module_id, level) DO UPDATE SET
			score = cyber_level_progress.score + $4,
			stars = LEAST(cyber_level_progress.stars + 1, 3),
			is_completed = TRUE,
			updated_at = NOW()
	`, userID, moduleID, level, xp)
	return err
}

func (r *Repository) UpdateUserXP(userID int64, xp int) error {
	_, err := r.db.Exec("UPDATE users SET total_xp = total_xp + $1, updated_at = NOW() WHERE id = $2", xp, userID)
	return err
}
