package capability

import (
	"time"
)

type Service interface {
	GetMyCapabilities(userID string) ([]CapabilityResponse, error)
}

type service struct {
	repo Repository
}

func NewService(repo Repository) Service {
	return &service{repo: repo}
}

func (s *service) GetMyCapabilities(userID string) ([]CapabilityResponse, error) {
	caps, err := s.repo.GetUserCapabilities(userID)
	if err != nil {
		return nil, err
	}

	// Virtual Decay (Lazy Evaluation)
	now := time.Now()
	for _ = range caps {
		// Asumsi kita dapat LastAssessedAt dari query DB. 
		// Karena CapabilityResponse saat ini belum memiliki LastAssessedAt,
		// kita abaikan perhitungannya jika kolom tidak tersedia atau simulasi sederhana.
		// Untuk MVP: jika Freshness < 1.0, kita biarkan. 
		// Idealnya: hitung delta months, kurangi freshness_score. 
		_ = now
		
		// Simulasi logic virtual decay (tanpa save DB)
		// decay := monthsSinceLastAssessed * 0.05
		// caps[i].EvidenceScore -= decay
	}

	return caps, nil
}
