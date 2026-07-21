package training

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

func (r *Repository) GetActiveCourses() ([]Course, error) {
	var courses []Course
	err := r.db.Select(&courses, "SELECT id, title, description, icon, ord, is_active, created_at FROM training_courses WHERE is_active = TRUE ORDER BY ord")
	if err != nil {
		return nil, fmt.Errorf("get courses: %w", err)
	}
	return courses, nil
}

func (r *Repository) GetActiveSections(courseID string) ([]Section, error) {
	var sections []Section
	query := "SELECT id, course_id, title, description, tier, ord, is_active, created_at FROM training_sections WHERE is_active = TRUE"
	args := []interface{}{}
	
	if courseID != "" {
		query += " AND course_id = $1"
		args = append(args, courseID)
	}
	query += " ORDER BY ord"
	
	err := r.db.Select(&sections, query, args...)
	if err != nil {
		return nil, fmt.Errorf("get sections: %w", err)
	}
	return sections, nil
}

func (r *Repository) GetSectionByID(id string) (*Section, error) {
	var s Section
	err := r.db.Get(&s, "SELECT id, course_id, title, description, tier, ord, is_active, created_at FROM training_sections WHERE id = $1 AND is_active = TRUE", id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get section: %w", err)
	}
	return &s, nil
}

func (r *Repository) GetUnitsBySection(sectionID string) ([]Unit, error) {
	var units []Unit
	err := r.db.Select(&units, "SELECT id, section_id, title, description, ord, total_levels, is_active FROM training_units WHERE section_id = $1 AND is_active = TRUE ORDER BY ord", sectionID)
	if err != nil {
		return nil, fmt.Errorf("get units: %w", err)
	}
	return units, nil
}

func (r *Repository) GetUnitByID(id string) (*Unit, error) {
	var u Unit
	err := r.db.Get(&u, "SELECT id, section_id, title, description, ord, total_levels, is_active FROM training_units WHERE id = $1 AND is_active = TRUE", id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get unit: %w", err)
	}
	return &u, nil
}

func (r *Repository) GetLevelsByUnit(unitID string) ([]Level, error) {
	var levels []Level
	err := r.db.Select(&levels, "SELECT id, unit_id, level_number, difficulty, total_questions, min_correct, xp_reward, unlock_rule, is_active FROM training_levels WHERE unit_id = $1 AND is_active = TRUE ORDER BY level_number", unitID)
	if err != nil {
		return nil, fmt.Errorf("get levels: %w", err)
	}
	return levels, nil
}

func (r *Repository) GetLevelByID(id string) (*Level, error) {
	var l Level
	err := r.db.Get(&l, "SELECT id, unit_id, level_number, difficulty, total_questions, min_correct, xp_reward, unlock_rule, is_active FROM training_levels WHERE id = $1 AND is_active = TRUE", id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get level: %w", err)
	}
	return &l, nil
}

func (r *Repository) GetQuestionsByLevel(levelID string) ([]Question, error) {
	var questions []Question
	rows, err := r.db.Queryx("SELECT id, level_id, type, question, payload, xp, ord, source, difficulty_level FROM training_questions WHERE level_id = $1 AND is_active = TRUE ORDER BY ord", levelID)
	if err != nil {
		return nil, fmt.Errorf("get questions: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var q Question
		var payloadStr string
		err := rows.Scan(&q.ID, &q.LevelID, &q.Type, &q.Question, &payloadStr, &q.Xp, &q.Ord, &q.Source, &q.DifficultyLevel)
		if err != nil {
			return nil, fmt.Errorf("scan question: %w", err)
		}
		var payload interface{}
		if err := json.Unmarshal([]byte(payloadStr), &payload); err != nil {
			return nil, fmt.Errorf("parse question payload: %w", err)
		}
		q.Payload = payload
		questions = append(questions, q)
	}
	return questions, nil
}

func (r *Repository) GetQuestionsByUnit(unitID string) ([]Question, error) {
	var questions []Question
	rows, err := r.db.Queryx(`
		SELECT q.id, q.level_id, q.type, q.question, q.payload, q.xp, q.ord, q.source, q.difficulty_level
		FROM training_questions q
		JOIN training_levels l ON q.level_id = l.id
		WHERE l.unit_id = $1 AND l.is_active = TRUE AND q.is_active = TRUE 
		ORDER BY l.level_number, q.ord
	`, unitID)
	if err != nil {
		return nil, fmt.Errorf("get questions by unit: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var q Question
		var payloadStr string
		err := rows.Scan(&q.ID, &q.LevelID, &q.Type, &q.Question, &payloadStr, &q.Xp, &q.Ord, &q.Source, &q.DifficultyLevel)
		if err != nil {
			return nil, fmt.Errorf("scan question: %w", err)
		}
		var payload interface{}
		if err := json.Unmarshal([]byte(payloadStr), &payload); err != nil {
			return nil, fmt.Errorf("parse question payload: %w", err)
		}
		q.Payload = payload
		questions = append(questions, q)
	}
	return questions, nil
}

func (r *Repository) GetUserProgress(userID int64, levelID string) (*UserProgress, error) {
	var up UserProgress
	err := r.db.Get(&up, "SELECT id, user_id, level_id, status, score, total_questions, correct_answers, xp_earned, time_spent_seconds, completed_at FROM user_progress WHERE user_id = $1 AND level_id = $2", userID, levelID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get progress: %w", err)
	}
	return &up, nil
}

func (r *Repository) GetUserProgressByLevelIDs(userID int64, levelIDs []string) (map[string]UserProgress, error) {
	if len(levelIDs) == 0 {
		return map[string]UserProgress{}, nil
	}

	q, args, err := sqlx.In("SELECT id, user_id, level_id, status, score, total_questions, correct_answers, xp_earned, time_spent_seconds, completed_at FROM user_progress WHERE user_id = ? AND level_id IN (?)", userID, levelIDs)
	if err != nil {
		return nil, fmt.Errorf("build progress query: %w", err)
	}
	q = r.db.Rebind(q)

	rows, err := r.db.Queryx(q, args...)
	if err != nil {
		return nil, fmt.Errorf("get progress batch: %w", err)
	}
	defer rows.Close()

	result := make(map[string]UserProgress)
	for rows.Next() {
		var up UserProgress
		if err := rows.Scan(&up.ID, &up.UserID, &up.LevelID, &up.Status, &up.Score, &up.TotalQuestions, &up.CorrectAnswers, &up.XpEarned, &up.TimeSpentSec, &up.CompletedAt); err != nil {
			return nil, fmt.Errorf("scan progress: %w", err)
		}
		result[up.LevelID] = up
	}
	return result, nil
}

func (r *Repository) UpsertProgress(userID int64, levelID string, score, correct, total, xp, timeSpent int) error {
	existing, err := r.GetUserProgress(userID, levelID)
	if err != nil {
		return err
	}

	if existing != nil {
		newScore := score
		if existing.Score > newScore {
			newScore = existing.Score
		}
		_, err = r.db.Exec(`
			UPDATE user_progress SET status = 'COMPLETED', score = $1, total_questions = $2,
			correct_answers = $3, xp_earned = xp_earned + $4, time_spent_seconds = time_spent_seconds + $5,
			completed_at = NOW(), updated_at = NOW()
			WHERE user_id = $6 AND level_id = $7
		`, newScore, total, correct, xp, timeSpent, userID, levelID)
	} else {
		_, err = r.db.Exec(`
			INSERT INTO user_progress (user_id, level_id, status, score, total_questions, correct_answers, xp_earned, time_spent_seconds, completed_at)
			VALUES ($1, $2, 'COMPLETED', $3, $4, $5, $6, $7, NOW())
		`, userID, levelID, score, total, correct, xp, timeSpent)
	}
	return err
}

func (r *Repository) UpdateUserXP(userID int64, xp int) error {
	_, err := r.db.Exec("UPDATE users SET total_xp = total_xp + $1, updated_at = NOW() WHERE id = $2", xp, userID)
	return err
}

func (r *Repository) GetProgressSummary(userID int64) ([]ProgressSummary, error) {
	var summary []ProgressSummary
	err := r.db.Select(&summary, `
		SELECT
			s.id AS section_id,
			s.title AS section_title,
			COUNT(DISTINCT CASE WHEN up.status = 'COMPLETED' THEN l.id END) AS completed,
			COUNT(DISTINCT l.id) AS total
		FROM training_sections s
		JOIN training_units u ON u.section_id = s.id
		JOIN training_levels l ON l.unit_id = u.id AND l.is_active = TRUE
		LEFT JOIN user_progress up ON up.level_id = l.id AND up.user_id = $1
		WHERE s.is_active = TRUE AND u.is_active = TRUE
		GROUP BY s.id, s.title, s.ord
		ORDER BY s.ord
	`, userID)
	if err != nil {
		return nil, fmt.Errorf("get progress summary: %w", err)
	}
	return summary, nil
}

func (r *Repository) GetQuestionsByLevelAndDifficulty(levelID string, minDiff, maxDiff int, limit int) ([]Question, error) {
	var questions []Question
	rows, err := r.db.Queryx(`
		SELECT id, level_id, type, question, payload, xp, ord, source, difficulty_level
		FROM training_questions
		WHERE level_id = $1
		  AND difficulty_level BETWEEN $2 AND $3
		  AND source = 'ai_generated'
		  AND is_active = TRUE
		ORDER BY generated_at DESC
		LIMIT $4
	`, levelID, minDiff, maxDiff, limit)
	if err != nil {
		return nil, fmt.Errorf("get personalized questions: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var q Question
		var payloadStr string
		err := rows.Scan(&q.ID, &q.LevelID, &q.Type, &q.Question, &payloadStr, &q.Xp, &q.Ord, &q.Source, &q.DifficultyLevel)
		if err != nil {
			return nil, fmt.Errorf("scan personalized question: %w", err)
		}
		var payload interface{}
		if err := json.Unmarshal([]byte(payloadStr), &payload); err != nil {
			return nil, fmt.Errorf("parse personalized payload: %w", err)
		}
		q.Payload = payload
		questions = append(questions, q)
	}
	return questions, nil
}

func (r *Repository) GetStaticQuestionsByLevel(levelID string, limit int) ([]Question, error) {
	var questions []Question
	rows, err := r.db.Queryx(`
		SELECT id, level_id, type, question, payload, xp, ord, source, difficulty_level
		FROM training_questions
		WHERE level_id = $1 AND source = 'static' AND is_active = TRUE
		ORDER BY ord
		LIMIT $2
	`, levelID, limit)
	if err != nil {
		return nil, fmt.Errorf("get static questions: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var q Question
		var payloadStr string
		err := rows.Scan(&q.ID, &q.LevelID, &q.Type, &q.Question, &payloadStr, &q.Xp, &q.Ord, &q.Source, &q.DifficultyLevel)
		if err != nil {
			return nil, fmt.Errorf("scan static question: %w", err)
		}
		var payload interface{}
		if err := json.Unmarshal([]byte(payloadStr), &payload); err != nil {
			return nil, fmt.Errorf("parse static payload: %w", err)
		}
		q.Payload = payload
		questions = append(questions, q)
	}
	return questions, nil
}

func (r *Repository) GetUserTotalXP(userID int64) (int64, error) {
	var xp int64
	err := r.db.Get(&xp, "SELECT COALESCE(total_xp, 0) FROM users WHERE id = $1", userID)
	if err != nil {
		return 0, fmt.Errorf("get user xp: %w", err)
	}
	return xp, nil
}

type Incident struct {
	ID              string      `db:"id" json:"id"`
	LevelID         string      `db:"level_id" json:"level_id"`
	Type            string      `db:"type" json:"type"`
	Question        string      `db:"question" json:"question"`
	Payload         interface{} `json:"payload"`
	XP              int         `db:"xp" json:"xp"`
	Ord             int         `db:"ord" json:"ord"`
	Source          string      `db:"source" json:"source"`
	DifficultyLevel int         `db:"difficulty_level" json:"difficulty_level"`
	SourceURL       string      `db:"source_url" json:"source_url"`
	GeneratedAt     string      `db:"generated_at" json:"generated_at"`
}

func (r *Repository) GetIncidents(limit int) ([]Incident, error) {
	if limit <= 0 || limit > 50 {
		limit = 20
	}
	var incidents []Incident
	rows, err := r.db.Queryx(`
		SELECT id, level_id, type, question, payload, xp, ord, source,
		       difficulty_level, COALESCE(source_url, '') as source_url,
		       COALESCE(generated_at::text, '') as generated_at
		FROM training_questions
		WHERE source = 'ai_generated' AND is_active = TRUE
		ORDER BY generated_at DESC, ord ASC
		LIMIT $1
	`, limit)
	if err != nil {
		return nil, fmt.Errorf("get incidents: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var inc Incident
		var payloadStr string
		err := rows.Scan(&inc.ID, &inc.LevelID, &inc.Type, &inc.Question, &payloadStr,
			&inc.XP, &inc.Ord, &inc.Source, &inc.DifficultyLevel, &inc.SourceURL, &inc.GeneratedAt)
		if err != nil {
			return nil, fmt.Errorf("scan incident: %w", err)
		}
		var payload interface{}
		if err := json.Unmarshal([]byte(payloadStr), &payload); err != nil {
			payload = payloadStr
		}
		inc.Payload = payload
		incidents = append(incidents, inc)
	}
	return incidents, nil
}
