package policies

import "time"

type Policy struct {
	IdleTimeout time.Duration
	MaxDuration time.Duration
	MergeGap    time.Duration
}

type Provider interface {
	GetPolicy(sourceEngine string) Policy
}

type defaultProvider struct{}

func NewDefaultProvider() Provider {
	return &defaultProvider{}
}

func (p *defaultProvider) GetPolicy(sourceEngine string) Policy {
	switch sourceEngine {
	case "coding":
		return Policy{
			IdleTimeout: 20 * time.Minute,
			MaxDuration: 12 * time.Hour,
			MergeGap:    10 * time.Minute,
		}
	case "reading":
		return Policy{
			IdleTimeout: 90 * time.Minute,
			MaxDuration: 24 * time.Hour,
			MergeGap:    15 * time.Minute,
		}
	case "video":
		return Policy{
			IdleTimeout: 60 * time.Minute,
			MaxDuration: 12 * time.Hour,
			MergeGap:    15 * time.Minute,
		}
	default: // workspace, etc
		return Policy{
			IdleTimeout: 30 * time.Minute,
			MaxDuration: 12 * time.Hour,
			MergeGap:    15 * time.Minute,
		}
	}
}
