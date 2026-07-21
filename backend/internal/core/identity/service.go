package identity

import "log"

type Service interface {
	GetFullProfile(userID string) (*ProfileResponse, error)
	UpdateProfile(userID string, req *UpdateProfileRequest) (*LearnerProfile, error)
	Onboard(userID string, req *OnboardingRequest) error
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) GetFullProfile(userID string) (*ProfileResponse, error) {
	profile, err := s.repo.GetProfile(userID)
	if err != nil {
		if err == ErrProfileNotFound {
			// Return empty profile gracefully for fresh users
			profile = &LearnerProfile{UserID: userID}
		} else {
			return nil, err
		}
	}

	devices, _ := s.repo.GetDevices(userID)
	interests, _ := s.repo.GetInterests(userID)

	return &ProfileResponse{
		Profile:   profile,
		Devices:   devices,
		Interests: interests,
	}, nil
}

func (s *service) UpdateProfile(userID string, req *UpdateProfileRequest) (*LearnerProfile, error) {
	profile, err := s.repo.GetProfile(userID)
	if err != nil {
		if err == ErrProfileNotFound {
			profile = &LearnerProfile{
				UserID:                userID,
				PersonaVersion:        "v1",
				IdentitySchemaVersion: "v1",
			}
		} else {
			return nil, err
		}
	}

	if err := MapUpdateToModel(req, profile); err != nil {
		return nil, err
	}

	err = s.repo.UpsertProfile(profile)
	if err != nil {
		return nil, err
	}

	return profile, nil
}

func (s *service) Onboard(userID string, req *OnboardingRequest) error {
	profile, _ := s.repo.GetProfile(userID)
	if profile == nil {
		profile = &LearnerProfile{
			UserID:                userID,
			PersonaVersion:        "v1",
			IdentitySchemaVersion: "v1",
		}
	}

	if err := MapUpdateToModel(&req.Profile, profile); err != nil {
		return err
	}
	
	// Mark as onboarded
	profile.OnboardingCompleted = true

	// Transaction-like behaviour without actual tx for simplicity here
	if err := s.repo.UpsertProfile(profile); err != nil {
		return err
	}

	s.repo.ClearDevices(userID)
	for _, dReq := range req.Devices {
		if ValidateCapability(dReq.CapabilityScore) {
			s.repo.AddDevice(&UserDevice{
				UserID:          userID,
				Platform:        dReq.Platform,
				OS:              dReq.OS,
				CapabilityScore: dReq.CapabilityScore,
			})
		}
	}

	s.repo.ClearInterests(userID)
	for _, interestStr := range req.Interests {
		s.repo.AddInterest(&UserInterest{
			UserID:   userID,
			Interest: interestStr,
		})
	}

	log.Printf("User %s onboarded successfully", userID)
	return nil
}
