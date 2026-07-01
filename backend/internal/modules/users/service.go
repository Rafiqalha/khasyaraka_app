package users

import "fmt"

type Service struct {
	repo *Repository
}

func NewService(repo *Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetProfile(userID int64) (*Profile, error) {
	user, err := s.repo.GetByID(userID)
	if err != nil {
		return nil, fmt.Errorf("get profile: %w", err)
	}
	if user == nil {
		return nil, fmt.Errorf("user not found")
	}
	return user, nil
}

func (s *Service) UpdateProfile(userID int64, fullName, timezone *string) (*Profile, error) {
	if err := s.repo.UpdateProfile(userID, fullName, timezone); err != nil {
		return nil, fmt.Errorf("update profile: %w", err)
	}
	return s.repo.GetByID(userID)
}

func (s *Service) UpdateAvatar(userID int64, pictureURL string) (*Profile, error) {
	if err := s.repo.UpdatePictureURL(userID, pictureURL); err != nil {
		return nil, fmt.Errorf("update avatar: %w", err)
	}
	return s.repo.GetByID(userID)
}

func (s *Service) GetPublicProfile(userID int64) (*PublicProfile, error) {
	user, err := s.repo.GetByID(userID)
	if err != nil {
		return nil, fmt.Errorf("get public profile: %w", err)
	}
	if user == nil {
		return nil, fmt.Errorf("user not found")
	}
	return &PublicProfile{
		ID:             user.ID,
		FullName:       user.FullName,
		PictureURL:     user.PictureURL,
		TotalXP:        user.TotalXP,
		HackLevel:      user.HackLevel,
		DecryptedCount: user.DecryptedCount,
		Streak:         user.Streak,
		Hearts:         user.Hearts,
	}, nil
}
