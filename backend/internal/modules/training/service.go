package training

import (
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"

	"github.com/khasyaraka/backend/internal/modules/users"
	"github.com/khasyaraka/backend/internal/xp"
)

type Service struct {
	repo *Repository
	rdb  *redis.Client
	db   *sqlx.DB
}

func NewService(repo *Repository, rdb *redis.Client, db *sqlx.DB) *Service {
	return &Service{repo: repo, rdb: rdb, db: db}
}

func (s *Service) GetSections() ([]Section, error) {
	return s.repo.GetActiveSections()
}

func (s *Service) GetSectionDetail(id string, userID *int64) (*Section, error) {
	sec, err := s.repo.GetSectionByID(id)
	if err != nil {
		return nil, err
	}
	if sec == nil {
		return nil, fmt.Errorf("section not found")
	}

	units, err := s.repo.GetUnitsBySection(id)
	if err != nil {
		return nil, err
	}

	if userID != nil {
		for i := range units {
			levels, err := s.repo.GetLevelsByUnit(units[i].ID)
			if err != nil {
				return nil, err
			}
			levelIDs := make([]string, len(levels))
			for j, l := range levels {
				levelIDs[j] = l.ID
			}
			progressMap, err := s.repo.GetUserProgressByLevelIDs(*userID, levelIDs)
			if err != nil {
				return nil, err
			}
			for _, l := range levels {
				lr := LevelResp{
					ID:             l.ID,
					UnitID:         l.UnitID,
					LevelNumber:    l.LevelNumber,
					Difficulty:     l.Difficulty,
					TotalQuestions: l.TotalQuestions,
					MinCorrect:     l.MinCorrect,
					XpReward:       l.XpReward,
					Status:         "LOCKED",
				}
				if p, ok := progressMap[l.ID]; ok {
					lr.Status = p.Status
					lr.Score = p.Score
				}
				if l.LevelNumber == 1 && lr.Status == "LOCKED" {
					lr.Status = "AVAILABLE"
				}
				units[i].Levels = append(units[i].Levels, lr)
			}
		}
	} else {
		for i := range units {
			levels, err := s.repo.GetLevelsByUnit(units[i].ID)
			if err != nil {
				return nil, err
			}
			for _, l := range levels {
				status := "LOCKED"
				if l.LevelNumber == 1 {
					status = "AVAILABLE"
				}
				units[i].Levels = append(units[i].Levels, LevelResp{
					ID:             l.ID,
					UnitID:         l.UnitID,
					LevelNumber:    l.LevelNumber,
					Difficulty:     l.Difficulty,
					TotalQuestions: l.TotalQuestions,
					MinCorrect:     l.MinCorrect,
					XpReward:       l.XpReward,
					Status:         status,
				})
			}
		}
	}

	sec.Units = units
	return sec, nil
}

func (s *Service) GetUnitDetail(id string, userID *int64) (*Unit, error) {
	u, err := s.repo.GetUnitByID(id)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, fmt.Errorf("unit not found")
	}

	levels, err := s.repo.GetLevelsByUnit(id)
	if err != nil {
		return nil, err
	}

	levelIDs := make([]string, len(levels))
	for i, l := range levels {
		levelIDs[i] = l.ID
	}

	var progressMap map[string]UserProgress
	if userID != nil {
		progressMap, err = s.repo.GetUserProgressByLevelIDs(*userID, levelIDs)
		if err != nil {
			return nil, err
		}
	}

	for _, l := range levels {
		lr := LevelResp{
			ID:             l.ID,
			UnitID:         l.UnitID,
			LevelNumber:    l.LevelNumber,
			Difficulty:     l.Difficulty,
			TotalQuestions: l.TotalQuestions,
			MinCorrect:     l.MinCorrect,
			XpReward:       l.XpReward,
			Status:         "LOCKED",
		}
		if progressMap != nil {
			if p, ok := progressMap[l.ID]; ok {
				lr.Status = p.Status
				lr.Score = p.Score
			}
		}
		if l.LevelNumber == 1 && lr.Status == "LOCKED" {
			lr.Status = "AVAILABLE"
		}
		u.Levels = append(u.Levels, lr)
	}

	return u, nil
}

func stripCorrectAnswer(v interface{}) interface{} {
	m, ok := v.(map[string]interface{})
	if !ok {
		return v
	}
	delete(m, "correct_answer")
	for k, val := range m {
		m[k] = stripCorrectAnswer(val)
	}
	return m
}

func (s *Service) GetLevelQuestions(id string, userID int64) (*Level, []Question, error) {
	l, err := s.repo.GetLevelByID(id)
	if err != nil {
		return nil, nil, err
	}
	if l == nil {
		return nil, nil, fmt.Errorf("level not found")
	}

	questions, err := s.repo.GetQuestionsByLevel(id)
	if err != nil {
		return nil, nil, err
	}

	for i := range questions {
		questions[i].Payload = stripCorrectAnswer(questions[i].Payload)
	}

	return l, questions, nil
}

// SubmitResult holds the result of a level submission including streak info.
type SubmitResult struct {
	Score         int                 `json:"score"`
	Correct       int                 `json:"correct"`
	XpEarned      int                 `json:"xp"`
	Streak        *users.StreakResult  `json:"streak,omitempty"`
}

func (s *Service) SubmitLevel(userID int64, levelID string, req SubmitRequest) (*SubmitResult, error) {
	l, err := s.repo.GetLevelByID(levelID)
	if err != nil {
		return nil, err
	}
	if l == nil {
		return nil, fmt.Errorf("level not found")
	}

	questions, err := s.repo.GetQuestionsByLevel(levelID)
	if err != nil {
		return nil, err
	}

	answerMap := make(map[string]string, len(req.Answers))
	for _, a := range req.Answers {
		answerMap[a.QuestionID] = a.Answer
	}

	correct := 0
	xpEarned := 0
	for _, q := range questions {
		if userAns, ok := answerMap[q.ID]; ok {
			payload, ok := q.Payload.(map[string]interface{})
			if ok {
				if correctAns, exists := payload["correct_answer"]; exists {
					if fmt.Sprintf("%v", correctAns) == userAns {
						correct++
						xpEarned += q.Xp
					}
				}
			}
		}
	}

	total := len(questions)
	score := 0
	if total > 0 {
		score = (correct * 100) / total
	}

	if err := s.repo.UpsertProgress(userID, levelID, score, correct, total, xpEarned, req.TimeSpent); err != nil {
		return nil, err
	}

	if err := s.repo.UpdateUserXP(userID, xpEarned); err != nil {
		return nil, err
	}

	if err := xp.SyncToRedis(s.repo.db, s.rdb, userID); err != nil {
		return nil, err
	}

	// Update daily streak (atomic, timezone-aware)
	var streakResult *users.StreakResult
	sr, err := users.UpdateStreakAtomic(s.db, userID, "")
	if err == nil {
		streakResult = sr
	}
	// Don't fail the submission if streak update fails

	return &SubmitResult{
		Score:    score,
		Correct:  correct,
		XpEarned: xpEarned,
		Streak:   streakResult,
	}, nil
}

func (s *Service) GetProgress(userID int64) ([]ProgressSummary, error) {
	return s.repo.GetProgressSummary(userID)
}


