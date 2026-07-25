// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package sku

import (
	"context"
	"fmt"
	"time"

	"github.com/pradigi/backend/internal/legacy/chat"
)

type Service struct {
	repo        *Repository
	chatService *chat.Service
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) SetChatService(cs *chat.Service) {
	s.chatService = cs
}

func stripQuizAnswers(v interface{}) interface{} {
	m, ok := v.(map[string]interface{})
	if !ok {
		return v
	}
	if items, ok := m["items"].([]interface{}); ok {
		for i, item := range items {
			if it, ok := item.(map[string]interface{}); ok {
				delete(it, "correct_answer")
				items[i] = it
			}
		}
	}
	return m
}

func (s *Service) GetPoints(userID *int64) ([]SKUPoint, error) {
	points, err := s.repo.GetPoints()
	if err != nil {
		return nil, err
	}

	for i := range points {
		points[i].QuizContent = stripQuizAnswers(points[i].QuizContent)
	}

	if userID != nil {
		progress, err := s.repo.GetProgress(*userID)
		if err != nil {
			return nil, err
		}
		for i := range points {
			if p, ok := progress[points[i].ID]; ok {
				points[i].IsCompleted = p.IsCompleted
				points[i].Score = p.Score
			}
		}
	}
	return points, nil
}

func (s *Service) GetPoint(id string, userID *int64) (*SKUPoint, error) {
	p, err := s.repo.GetPointByID(id)
	if err != nil {
		return nil, err
	}
	if p == nil {
		return nil, fmt.Errorf("sku point not found")
	}

	p.QuizContent = stripQuizAnswers(p.QuizContent)

	if userID != nil {
		progress, err := s.repo.GetProgress(*userID)
		if err != nil {
			return nil, err
		}
		if pr, ok := progress[p.ID]; ok {
			p.IsCompleted = pr.IsCompleted
			p.Score = pr.Score
		}
	}
	return p, nil
}

func (s *Service) SubmitQuiz(userID int64, pointID string, answers []string) (int, error) {
	p, err := s.repo.GetPointByID(pointID)
	if err != nil {
		return 0, err
	}
	if p == nil {
		return 0, fmt.Errorf("sku point not found")
	}

	quiz, ok := p.QuizContent.(map[string]interface{})
	if !ok {
		return 0, fmt.Errorf("invalid quiz content")
	}

	items, ok := quiz["items"].([]interface{})
	if !ok {
		return 0, fmt.Errorf("invalid quiz items")
	}

	correct := 0
	for i, item := range items {
		if i >= len(answers) {
			break
		}
		q, ok := item.(map[string]interface{})
		if !ok {
			continue
		}
		correctAns, has := q["correct_answer"]
		if has && fmt.Sprintf("%v", correctAns) == answers[i] {
			correct++
		}
	}

	total := len(items)
	score := 0
	if total > 0 {
		score = (correct * 100) / total
	}

	if err := s.repo.MarkCompleted(userID, pointID, score); err != nil {
		return 0, err
	}

	if s.chatService != nil && score >= 100 {
		userRooms, _ := s.chatService.GetUserRooms(context.Background(), userID)
		if userRooms != nil && userRooms.Kecamatan != nil {
			content := fmt.Sprintf("🏆 Kamu baru saja melihat temanmu menyelesaikan %s! Selamat, Pramuka! 👏", p.Title)
			s.chatService.SendSystemMessage(context.Background(), userRooms.Kecamatan.ID, content)
		}
	}

	return score, nil
}

func (s *Service) CanUnlockHighestTier(ctx context.Context, userID int64) (bool, int, error) {
	firstActive, err := s.repo.GetFirstActiveDate(userID)
	if err != nil {
		return false, 90, err
	}

	loc, _ := time.LoadLocation("Asia/Jakarta")
	now := time.Now().In(loc)

	if !firstActive.Valid {
		// New user or missing date, set to today
		if err := s.repo.SetFirstActiveDateToToday(userID); err != nil {
			return false, 90, err
		}
		return false, 90, nil
	}

	// Calculate days since first active
	// Using end of today vs first active date midnight
	faDate := firstActive.Time.In(loc)
	faDateMidnight := time.Date(faDate.Year(), faDate.Month(), faDate.Day(), 0, 0, 0, 0, loc)
	nowMidnight := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)

	daysSinceFirstActive := int(nowMidnight.Sub(faDateMidnight).Hours() / 24)
	if daysSinceFirstActive < 0 {
		daysSinceFirstActive = 0
	}

	daysRemaining := 90 - daysSinceFirstActive
	if daysRemaining < 0 {
		daysRemaining = 0
	}

	return daysSinceFirstActive >= 90, daysRemaining, nil
}
