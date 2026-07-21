package events

import (
	"context"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

type mockSubscriber struct {
	mu     sync.Mutex
	events []Event
}

func (m *mockSubscriber) Handle(ctx context.Context, event Event) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.events = append(m.events, event)
	return nil
}

func (m *mockSubscriber) GetEvents() []Event {
	m.mu.Lock()
	defer m.mu.Unlock()
	return m.events
}

func TestInMemoryDispatcher(t *testing.T) {
	executor := NewGoroutineExecutor(nil, nil)
	dispatcher := NewInMemoryDispatcher(executor)

	sub := &mockSubscriber{}
	dispatcher.Subscribe(CapabilityUpdated, sub)

	event := Event{
		ID:            "test-event-1",
		Name:          CapabilityUpdated,
		AggregateType: "Capability",
		AggregateID:   "cap-123",
	}

	err := dispatcher.Publish(context.Background(), event)
	assert.NoError(t, err)

	// Wait for goroutine to process
	time.Sleep(50 * time.Millisecond)

	events := sub.GetEvents()
	assert.Len(t, events, 1)
	assert.Equal(t, "test-event-1", events[0].ID)
	assert.Equal(t, CapabilityUpdated, events[0].Name)

	metrics := GetEventMetrics()
	assert.Equal(t, int64(1), metrics[CapabilityUpdated].PublishTotal)
}
