package subscription

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetStatus(userID int64) (*Subscription, error) {
	return s.repo.GetActiveByUser(userID)
}

func (s *Service) Create(userID int64, tier, paymentRef, provider string) (*Subscription, error) {
	return s.repo.Create(userID, tier, paymentRef, provider)
}

func (s *Service) Cancel(userID int64) error {
	return s.repo.Cancel(userID)
}
