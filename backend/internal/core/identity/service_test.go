package identity

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

type mockRepo struct {
	profile   *LearnerProfile
	devices   []UserDevice
	interests []UserInterest
	err       error
}

func (m *mockRepo) GetProfile(userID string) (*LearnerProfile, error) {
	if m.err != nil {
		return nil, m.err
	}
	if m.profile == nil {
		return nil, ErrProfileNotFound
	}
	return m.profile, nil
}

func (m *mockRepo) UpsertProfile(profile *LearnerProfile) error {
	m.profile = profile
	return nil
}

func (m *mockRepo) GetDevices(userID string) ([]UserDevice, error) {
	return m.devices, nil
}

func (m *mockRepo) AddDevice(device *UserDevice) error {
	m.devices = append(m.devices, *device)
	return nil
}

func (m *mockRepo) ClearDevices(userID string) error {
	m.devices = []UserDevice{}
	return nil
}

func (m *mockRepo) GetInterests(userID string) ([]UserInterest, error) {
	return m.interests, nil
}

func (m *mockRepo) AddInterest(interest *UserInterest) error {
	m.interests = append(m.interests, *interest)
	return nil
}

func (m *mockRepo) ClearInterests(userID string) error {
	m.interests = []UserInterest{}
	return nil
}

func TestGetFullProfile_Existing(t *testing.T) {
	repo := &mockRepo{
		profile: &LearnerProfile{UserID: "123", DisplayName: "John"},
		devices: []UserDevice{{Platform: "web"}},
	}
	svc := NewService(repo)

	res, err := svc.GetFullProfile("123")
	assert.NoError(t, err)
	assert.Equal(t, "John", res.Profile.DisplayName)
	assert.Len(t, res.Devices, 1)
}

func TestGetFullProfile_NotFoundGraceful(t *testing.T) {
	repo := &mockRepo{}
	svc := NewService(repo)

	res, err := svc.GetFullProfile("123")
	assert.NoError(t, err)
	assert.Equal(t, "123", res.Profile.UserID)
}

func TestOnboard_Success(t *testing.T) {
	repo := &mockRepo{}
	svc := NewService(repo)

	goal := GoalBuildStartup
	persona := PersonaMentor
	stage := StageLearn

	req := &OnboardingRequest{
		Profile: UpdateProfileRequest{
			LearningGoalType: &goal,
			AIPersona:        &persona,
			CurrentStage:     &stage,
		},
		Devices: []DeviceRequest{
			{Platform: "web", CapabilityScore: CapabilityHigh},
		},
		Interests: []string{"AI", "Security"},
	}

	err := svc.Onboard("123", req)
	assert.NoError(t, err)

	assert.Equal(t, "123", repo.profile.UserID)
	assert.True(t, repo.profile.OnboardingCompleted)
	assert.Equal(t, GoalBuildStartup, repo.profile.LearningGoalType)
	assert.Equal(t, "v1", repo.profile.PersonaVersion)
	assert.Len(t, repo.devices, 1)
	assert.Len(t, repo.interests, 2)
}

func BenchmarkGetFullProfile(b *testing.B) {
	repo := &mockRepo{
		profile: &LearnerProfile{UserID: "123", DisplayName: "John"},
	}
	svc := NewService(repo)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, _ = svc.GetFullProfile("123")
	}
}

func BenchmarkOnboard(b *testing.B) {
	repo := &mockRepo{}
	svc := NewService(repo)

	goal := GoalBuildStartup
	req := &OnboardingRequest{
		Profile: UpdateProfileRequest{
			LearningGoalType: &goal,
		},
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_ = svc.Onboard("123", req)
	}
}
