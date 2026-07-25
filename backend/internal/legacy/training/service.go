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

func (s *Service) GetCourses() ([]Course, error) {
	return s.repo.GetActiveCourses()
}

func (s *Service) GetSections(courseID string) ([]Section, error) {
	return s.repo.GetActiveSections(courseID)
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
			// Cascade unlock within this unit
			for j := 0; j < len(units[i].Levels)-1; j++ {
				if units[i].Levels[j].Status == "COMPLETED" && units[i].Levels[j+1].Status == "LOCKED" {
					units[i].Levels[j+1].Status = "AVAILABLE"
				}
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
	// Cascade unlock within this unit
	for j := 0; j < len(u.Levels)-1; j++ {
		if u.Levels[j].Status == "COMPLETED" && u.Levels[j+1].Status == "LOCKED" {
			u.Levels[j+1].Status = "AVAILABLE"
		}
	}

	return u, nil
}

func (s *Service) GetLevelQuestions(id string, userID int64) (*Level, []Question, error) {
	l, err := s.repo.GetLevelByID(id)
	if err != nil {
		return nil, nil, err
	}
	if l == nil {
		return nil, nil, fmt.Errorf("level not found")
	}

	questions, err := s.GetPersonalizedQuestions(id, userID)
	if err != nil {
		return nil, nil, err
	}

	return l, questions, nil
}

func (s *Service) GetPersonalizedQuestions(levelID string, userID int64) ([]Question, error) {
	minDiff, maxDiff := calculateDifficultyBand(userID, s.repo)
	if minDiff == 0 {
		minDiff = 1
		maxDiff = 3
	}

	aiQuestions, err := s.repo.GetQuestionsByLevelAndDifficulty(levelID, minDiff, maxDiff, 3)
	if err != nil {
		aiQuestions = nil
	}

	staticQuestions, err := s.repo.GetStaticQuestionsByLevel(levelID, 2)
	if err != nil {
		staticQuestions = nil
	}

	totalQuestions := 5
	result := make([]Question, 0, totalQuestions)

	result = append(result, aiQuestions...)

	remaining := totalQuestions - len(result)
	if remaining > 0 && len(staticQuestions) > 0 {
		if remaining > len(staticQuestions) {
			remaining = len(staticQuestions)
		}
		result = append(result, staticQuestions[:remaining]...)
	}

	if len(result) == 0 {
		all, err := s.repo.GetQuestionsByLevel(levelID)
		if err != nil {
			return nil, fmt.Errorf("fallback questions: %w", err)
		}
		return all, nil
	}

	shuffleQuestions(result)
	return result, nil
}

func calculateDifficultyBand(userID int64, repo *Repository) (int, int) {
	if userID <= 0 {
		return 1, 3
	}
	xp, err := repo.GetUserTotalXP(userID)
	if err != nil {
		return 1, 3
	}

	switch {
	case xp < 5000:
		return 1, 3
	case xp < 20000:
		return 3, 6
	case xp < 50000:
		return 6, 8
	default:
		return 8, 10
	}
}

func shuffleQuestions(questions []Question) {
	for i := len(questions) - 1; i > 0; i-- {
		j := (i * 17) % len(questions)
		questions[i], questions[j] = questions[j], questions[i]
	}
}

func (s *Service) GetIncidents(limit int) ([]Incident, error) {
	return s.repo.GetIncidents(limit)
}

func (s *Service) GetQuestionsByUnit(unitID string) ([]Question, error) {
	return s.repo.GetQuestionsByUnit(unitID)
}

func (s *Service) GetQuestionsByLevel(levelID string) ([]Question, error) {
	return s.repo.GetQuestionsByLevel(levelID)
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

		// Cascade unlock: if level N is COMPLETED, level N+1 becomes AVAILABLE
		for i := range learningUnits {
			for j := range learningUnits[i].Levels {
				if learningUnits[i].Levels[j].Status == "COMPLETED" {
					// Unlock next level in same unit
					if j+1 < len(learningUnits[i].Levels) {
						if learningUnits[i].Levels[j+1].Status == "LOCKED" {
							learningUnits[i].Levels[j+1].Status = "AVAILABLE"
						}
					} else if i+1 < len(learningUnits) && len(learningUnits[i+1].Levels) > 0 {
						// Last level of unit completed, unlock first level of next unit
						if learningUnits[i+1].Levels[0].Status == "LOCKED" {
							learningUnits[i+1].Levels[0].Status = "AVAILABLE"
						}
					}
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
	Score    int                 `json:"score"`
	Correct  int                 `json:"correct"`
	XpEarned int                 `json:"xp"`
	Streak   *users.StreakResult `json:"streak,omitempty"`
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
		"success":         true,
		"level_id":        levelID,
		"status":          "COMPLETED",
		"score":           score,
		"correct_answers": correct,
		"total_questions": total,
		"xp_earned":       xpEarned,
		"total_xp":        0, // In full app we might fetch updated user total_xp here
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

// GetProgressState returns a flat map of levelId → status across all sections,
// with cascading unlock: if level N is COMPLETED, level N+1 becomes AVAILABLE.
func (s *Service) GetProgressState(userID int64, sectionID string) (map[string]string, error) {
	progress := make(map[string]string)

	var sections []Section
	if sectionID != "" {
		sec, err := s.repo.GetSectionByID(sectionID)
		if err != nil {
			return nil, err
		}
		if sec != nil {
			sections = []Section{*sec}
		}
	} else {
		courses, err := s.repo.GetActiveCourses()
		if err != nil {
			return nil, err
		}
		for _, course := range courses {
			secs, err := s.repo.GetActiveSections(course.ID)
			if err != nil {
				return nil, err
			}
			sections = append(sections, secs...)
		}
	}

	for _, sec := range sections {
		units, err := s.repo.GetUnitsBySection(sec.ID)
		if err != nil {
			continue
		}
		var allLevelIDs []string
		unitLevels := make(map[string][]Level)
		for _, u := range units {
			levels, err := s.repo.GetLevelsByUnit(u.ID)
			if err != nil {
				continue
			}
			unitLevels[u.ID] = levels
			for _, l := range levels {
				allLevelIDs = append(allLevelIDs, l.ID)
			}
		}

		userProgressMap, err := s.repo.GetUserProgressByLevelIDs(userID, allLevelIDs)
		if err != nil {
			continue
		}

		for _, u := range units {
			levels := unitLevels[u.ID]
			// PASS 1: assign base status from user progress
			for _, l := range levels {
				status := "LOCKED"
				if p, ok := userProgressMap[l.ID]; ok {
					status = p.Status
				}
				if l.LevelNumber == 1 && status == "LOCKED" {
					status = "AVAILABLE"
				}
				progress[l.ID] = status
			}
			// PASS 2: cascade unlock (separate loop to avoid overwriting)
			for j := 0; j < len(levels)-1; j++ {
				if progress[levels[j].ID] == "COMPLETED" && progress[levels[j+1].ID] == "LOCKED" {
					progress[levels[j+1].ID] = "AVAILABLE"
				}
			}
		}
	}

	return progress, nil
}
