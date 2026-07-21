package token

import (
	"context"
	"errors"
	"time"
)

type TokenService struct {
	repo Repository
}

func NewTokenService(repo Repository) *TokenService {
	return &TokenService{repo: repo}
}

func (s *TokenService) GetStatus(ctx context.Context, userID int64) (*TokenStatus, error) {
	err := s.repo.ResetIfNewDay(ctx, userID)
	if err != nil {
		return nil, err
	}

	userToken, err := s.repo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if userToken == nil {
		userToken, err = s.repo.Create(ctx, userID, TierFree, TierLimits[TierFree])
		if err != nil {
			return nil, err
		}
	}

	// Calculate resets_at = tomorrow 00:00 WIB in ISO8601
	loc, _ := time.LoadLocation("Asia/Jakarta")
	now := time.Now().In(loc)
	resetsAt := time.Date(now.Year(), now.Month(), now.Day()+1, 0, 0, 0, 0, loc).Format(time.RFC3339)

	return &TokenStatus{
		Tier:       userToken.Tier,
		DailyLimit: userToken.DailyLimit,
		UsedToday:  userToken.UsedToday,
		Remaining:  userToken.DailyLimit - userToken.UsedToday,
		ResetsAt:   resetsAt,
	}, nil
}

func (s *TokenService) ConsumeOne(ctx context.Context, userID int64) (*TokenStatus, error) {
	status, err := s.GetStatus(ctx, userID)
	if err != nil {
		return nil, err
	}
	if status.Remaining <= 0 {
		return status, errors.New("token limit reached")
	}

	err = s.repo.DeductOne(ctx, userID)
	if err != nil {
		return status, err
	}

	status.UsedToday++
	status.Remaining--
	return status, nil
}

func (s *TokenService) RefundOne(ctx context.Context, userID int64) error {
	return s.repo.RefundOne(ctx, userID)
}

func (s *TokenService) SetTierFromSubscription(ctx context.Context, userID int64, planName string) error {
	tier := TierFree
	limit := TierLimits[TierFree]

	switch planName {
	case "pro":
		tier = TierPro
		limit = TierLimits[TierPro]
	case "max":
		tier = TierMax
		limit = TierLimits[TierMax]
	}

	return s.repo.UpdateTier(ctx, userID, tier, limit)
}
