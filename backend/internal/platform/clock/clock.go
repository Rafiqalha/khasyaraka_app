package clock

import "time"

// Clock provides an abstraction over time to enable easier testing
type Clock interface {
	Now() time.Time
	Since(t time.Time) time.Duration
	Until(t time.Time) time.Duration
}

type realClock struct{}

func New() Clock {
	return &realClock{}
}

func (r *realClock) Now() time.Time {
	return time.Now()
}

func (r *realClock) Since(t time.Time) time.Duration {
	return time.Since(t)
}

func (r *realClock) Until(t time.Time) time.Duration {
	return time.Until(t)
}

// MockClock is used for testing
type MockClock struct {
	CurrentTime time.Time
}

func NewMock(t time.Time) *MockClock {
	return &MockClock{CurrentTime: t}
}

func (m *MockClock) Now() time.Time {
	return m.CurrentTime
}

func (m *MockClock) Since(t time.Time) time.Duration {
	return m.CurrentTime.Sub(t)
}

func (m *MockClock) Until(t time.Time) time.Duration {
	return t.Sub(m.CurrentTime)
}
