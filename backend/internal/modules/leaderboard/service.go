package leaderboard

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetTop(limit int) ([]Entry, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	return s.repo.GetTop(limit)
}

func (s *Service) GetUserRank(userID int64) (*UserRank, error) {
	return s.repo.GetUserRank(userID)
}
