// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package survival

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetStatus(userID int64) ([]Mastery, error) {
	return s.repo.GetByUser(userID)
}

func (s *Service) LogAction(userID int64, req ActionRequest) error {
	return s.repo.UpsertAction(userID, req.ToolType, req.Distance, req.Altitude, req.IsStreak)
}

func (s *Service) GetLeaderboard(limit int) ([]LeaderboardEntry, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return s.repo.GetLeaderboard(limit)
}
