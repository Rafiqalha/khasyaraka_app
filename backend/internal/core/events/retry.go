package events

import (
	"time"
)

type RetryStrategy interface {
	ShouldRetry(attempts int, event Event) bool
	NextDelay(attempts int, event Event) time.Duration
}

type DefaultRetryStrategy struct {
	MaxRetries int
	Delay      time.Duration
}

func (s *DefaultRetryStrategy) ShouldRetry(attempts int, event Event) bool {
	return attempts < s.MaxRetries
}

func (s *DefaultRetryStrategy) NextDelay(attempts int, event Event) time.Duration {
	return s.Delay
}
