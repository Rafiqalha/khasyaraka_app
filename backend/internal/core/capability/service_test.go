package capability

import (
	"testing"
	"github.com/stretchr/testify/assert"
)

type mockRepo struct {
	caps []CapabilityResponse
	err  error
}

func (m *mockRepo) GetUserCapabilities(userID string) ([]CapabilityResponse, error) {
	if m.err != nil {
		return nil, m.err
	}
	return m.caps, nil
}

func (m *mockRepo) UpsertCapability(cap *LearnerCapability) error {
	return nil
}

func (m *mockRepo) LogEvaluation(log *CapabilityLog) error {
	return nil
}

func TestGetMyCapabilities(t *testing.T) {
	repo := &mockRepo{
		caps: []CapabilityResponse{
			{SkillID: "skill-1", ProficiencyScore: 500, NormalizedScore: 50},
		},
	}
	svc := NewService(repo)

	res, err := svc.GetMyCapabilities("user-123")
	assert.NoError(t, err)
	assert.Len(t, res, 1)
	assert.Equal(t, 500, res[0].ProficiencyScore)
}

func BenchmarkGetMyCapabilities(b *testing.B) {
	repo := &mockRepo{
		caps: []CapabilityResponse{
			{SkillID: "skill-1", ProficiencyScore: 500},
			{SkillID: "skill-2", ProficiencyScore: 600},
		},
	}
	svc := NewService(repo)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, _ = svc.GetMyCapabilities("user-123")
	}
}
