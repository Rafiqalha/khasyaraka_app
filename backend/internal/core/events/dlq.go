package events

import (
	"context"
	"sync"
)

type DLQ interface {
	Push(ctx context.Context, event Event, err error) error
	GetItems(ctx context.Context) ([]Event, error)
}

type MemoryDLQ struct {
	mu    sync.RWMutex
	items []Event
}

func NewMemoryDLQ() *MemoryDLQ {
	return &MemoryDLQ{
		items: make([]Event, 0),
	}
}

func (q *MemoryDLQ) Push(ctx context.Context, event Event, err error) error {
	q.mu.Lock()
	defer q.mu.Unlock()
	q.items = append(q.items, event)
	return nil
}

func (q *MemoryDLQ) GetItems(ctx context.Context) ([]Event, error) {
	q.mu.RLock()
	defer q.mu.RUnlock()
	
	copyItems := make([]Event, len(q.items))
	copy(copyItems, q.items)
	return copyItems, nil
}
