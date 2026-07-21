package events

import (
	"context"
	"sync"
)

type inMemoryDispatcher struct {
	mu          sync.RWMutex
	subscribers map[EventName][]Subscriber
	executor    Executor
}

func NewInMemoryDispatcher(executor Executor) Dispatcher {
	return &inMemoryDispatcher{
		subscribers: make(map[EventName][]Subscriber),
		executor:    executor,
	}
}

func (d *inMemoryDispatcher) Subscribe(eventName EventName, handler Subscriber) {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.subscribers[eventName] = append(d.subscribers[eventName], handler)
}

func (d *inMemoryDispatcher) Publish(ctx context.Context, event Event) error {
	RecordEvent(event.Name)

	d.mu.RLock()
	handlers := d.subscribers[event.Name]
	d.mu.RUnlock()

	for _, handler := range handlers {
		// Route ke executor untuk concurrency
		d.executor.Execute(ctx, handler, event)
	}

	return nil
}
