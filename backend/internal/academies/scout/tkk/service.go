// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package tkk

import "fmt"

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetBadges(userID int64) ([]TKKBadge, error) {
	return s.repo.GetByUser(userID)
}

func (s *Service) Attain(userID int64, slug, level string) (*TKKBadge, error) {
	exists, err := s.repo.Exists(userID, slug, level)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, fmt.Errorf("badge already attained")
	}
	return s.repo.Create(userID, slug, level)
}
