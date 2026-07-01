package sku

import "fmt"

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
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

	return score, nil
}
