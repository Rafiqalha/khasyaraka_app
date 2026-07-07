package subscription

import (
	"context"
	"github.com/khasyaraka/backend/internal/modules/token"
)

type Service struct {
	repo         *Repository
	tokenService *token.TokenService
}

func NewService(repo *Repository, tokenService *token.TokenService) *Service {
	return &Service{
		repo:         repo,
		tokenService: tokenService,
	}
}

func (s *Service) GetStatus(userID int64) (*Subscription, error) {
	return s.repo.GetActiveByUser(userID)
}

func (s *Service) Create(userID int64, tier, paymentRef, provider string) (*Subscription, error) {
	sub, err := s.repo.Create(userID, tier, paymentRef, provider)
	if err != nil {
		return nil, err
	}
	
	// Update token tier
	err = s.tokenService.SetTierFromSubscription(context.Background(), userID, tier)
	if err != nil {
		// Log error but don't fail subscription
	}

	return sub, nil
}

func (s *Service) Cancel(userID int64) error {
	return s.repo.Cancel(userID)
}
