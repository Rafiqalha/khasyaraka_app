package training

import (
	"fmt"

	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"

	"github.com/pradigi/backend/internal/modules/users"
	"github.com/pradigi/backend/internal/xp"
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
					Title:          fmt.Sprintf("Level %d", l.LevelNumber),
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
					Title:          fmt.Sprintf("Level %d", l.LevelNumber),
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
			Title:          fmt.Sprintf("Level %d", l.LevelNumber),
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

func (s *Service) GetQuestionsByUnit(unitID string) ([]Question, error) {
	questions, err := s.repo.GetQuestionsByUnit(unitID)
	if err != nil {
		return nil, err
	}
	for i := range questions {
		questions[i].Payload = stripCorrectAnswer(questions[i].Payload)
	}
	return questions, nil
}

func (s *Service) GetQuestionsByLevel(levelID string) ([]Question, error) {
	questions, err := s.repo.GetQuestionsByLevel(levelID)
	if err != nil {
		return nil, err
	}
	for i := range questions {
		questions[i].Payload = stripCorrectAnswer(questions[i].Payload)
	}
	return questions, nil
}

func (s *Service) GetLearningPathForSection(sectionID string, userID *int64) (*LearningPathResponse, error) {
	sec, err := s.repo.GetSectionByID(sectionID)
	if err != nil {
		return nil, err
	}
	if sec == nil {
		return nil, nil
	}

	units, err := s.repo.GetUnitsBySection(sectionID)
	if err != nil {
		return nil, err
	}

	var allLevelIDs []string
	learningUnits := make([]LearningUnit, len(units))
	
	for i, u := range units {
		levels, err := s.repo.GetLevelsByUnit(u.ID)
		if err != nil {
			return nil, err
		}
		
		levelResps := make([]LevelResp, len(levels))
		for j, l := range levels {
			allLevelIDs = append(allLevelIDs, l.ID)
			levelResps[j] = LevelResp{
				ID:             l.ID,
				UnitID:         l.UnitID,
				LevelNumber:    l.LevelNumber,
				Title:          fmt.Sprintf("Level %d", l.LevelNumber),
				Difficulty:     l.Difficulty,
				TotalQuestions: l.TotalQuestions,
				MinCorrect:     l.MinCorrect,
				XpReward:       l.XpReward,
				Status:         "LOCKED", // default
			}
			if l.LevelNumber == 1 {
				levelResps[j].Status = "AVAILABLE"
			}
		}
		
		learningUnits[i] = LearningUnit{
			ID:          u.ID,
			SectionID:   sectionID,
			Title:       u.Title,
			Ord:         u.Ord,
			TotalLevels: u.TotalLevels,
			Levels:      levelResps,
		}
	}

	userProgress := make(map[string]string)
	if userID != nil {
		progressMap, err := s.repo.GetUserProgressByLevelIDs(*userID, allLevelIDs)
		if err != nil {
			return nil, err
		}
		for _, up := range progressMap {
			userProgress[up.LevelID] = up.Status
		}
		
		// Update statuses in the response tree
		for i := range learningUnits {
			for j := range learningUnits[i].Levels {
				lID := learningUnits[i].Levels[j].ID
				if status, ok := userProgress[lID]; ok {
					learningUnits[i].Levels[j].Status = status
				}
			}
		}
	}

	return &LearningPathResponse{
		SectionID:    sec.ID,
		SectionTitle: sec.Title,
		Units:        learningUnits,
		UserProgress: userProgress,
	}, nil
}

// SubmitResult holds the result of a level submission including streak info.
type SubmitResult struct {
	Score         int                 `json:"score"`
	Correct       int                 `json:"correct"`
	XpEarned      int                 `json:"xp"`
	Streak        *users.StreakResult  `json:"streak,omitempty"`
}

func (s *Service) SubmitLevel(userID int64, levelID string, req SubmitRequest) (map[string]interface{}, error) {
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

	// Calculate XP earned purely from correct_question_ids to prevent manipulation
	correct := 0
	xpEarned := 0
	
	correctIDs := make(map[string]bool)
	for _, id := range req.CorrectQuestionIDs {
		correctIDs[id] = true
	}
	
	for _, q := range questions {
		if correctIDs[q.ID] {
			correct++
			xpEarned += q.Xp
		}
	}

	total := len(questions)
	score := req.Score // take score from client, but XP is verified
	if total > 0 && req.Score == 0 && correct > 0 {
		score = (correct * 100) / total
	}

	if err := s.repo.UpsertProgress(userID, levelID, score, correct, total, xpEarned, req.TimeSpentSec); err != nil {
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
	
	// Create result map that matches the Python backend response expected by Flutter
	result := map[string]interface{}{
		"success": true,
		"level_id": levelID,
		"status": "COMPLETED",
		"score": score,
		"correct_answers": correct,
		"total_questions": total,
		"xp_earned": xpEarned,
		"total_xp": 0, // In full app we might fetch updated user total_xp here
	}
	
	if streakResult != nil {
		result["streak"] = streakResult.Streak
		result["longest_streak"] = streakResult.LongestStreak
		result["last_active_date"] = streakResult.LastActiveDate
	}

	return result, nil
}

func (s *Service) GetProgress(userID int64) ([]ProgressSummary, error) {
	return s.repo.GetProgressSummary(userID)
}


