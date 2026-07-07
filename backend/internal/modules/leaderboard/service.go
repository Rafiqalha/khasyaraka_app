package leaderboard

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetTop(category string, scope string, locationID string, limit int) ([]Entry, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return s.repo.GetTop(category, scope, locationID, limit)
}

func (s *Service) GetUserRank(userID int64, category string, scope string, locationID string) (*UserRank, error) {
	return s.repo.GetUserRank(userID, category, scope, locationID)
}
