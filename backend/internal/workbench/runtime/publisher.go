package runtime

import (
	"time"
)

// ===========================
// Runtime Event Publisher
// Abstract interface for emitting fine-grained runtime events.
// Docker (or Kubernetes/Firecracker) implementations will push to this channel.
// ===========================

type RuntimeEvent struct {
	EnvID     string
	Type      string // "ContainerStarted", "Stdout", "Stderr", "ExecutionFinished"
	Payload   string
	Timestamp time.Time
}

type EventPublisher interface {
	Subscribe(envID string) chan RuntimeEvent
	Unsubscribe(envID string, ch chan RuntimeEvent)
	Publish(event RuntimeEvent)
}

type inMemoryPublisher struct {
	subscribers map[string][]chan RuntimeEvent
}

func NewEventPublisher() EventPublisher {
	return &inMemoryPublisher{
		subscribers: make(map[string][]chan RuntimeEvent),
	}
}

func (p *inMemoryPublisher) Subscribe(envID string) chan RuntimeEvent {
	ch := make(chan RuntimeEvent, 100)
	p.subscribers[envID] = append(p.subscribers[envID], ch)
	return ch
}

func (p *inMemoryPublisher) Unsubscribe(envID string, ch chan RuntimeEvent) {
	subs := p.subscribers[envID]
	for i, sub := range subs {
		if sub == ch {
			p.subscribers[envID] = append(subs[:i], subs[i+1:]...)
			break
		}
	}
	close(ch)
}

func (p *inMemoryPublisher) Publish(event RuntimeEvent) {
	subs, ok := p.subscribers[event.EnvID]
	if !ok {
		return
	}
	for _, ch := range subs {
		select {
		case ch <- event:
		default:
			// Non-blocking drop if channel is full
		}
	}
}
