package events

import (
	"sync"
	"time"
)

type EventMetrics struct {
	PublishTotal   int64
	FailedTotal    int64
	RetryTotal     int64
	DLQTotal       int64
	ProcessingTime time.Duration // Simplified for MVP
}

var (
	metricsMu sync.RWMutex
	metrics   = make(map[EventName]*EventMetrics)
)

func getOrCreateMetric(name EventName) *EventMetrics {
	if m, exists := metrics[name]; exists {
		return m
	}
	m := &EventMetrics{}
	metrics[name] = m
	return m
}

func RecordEvent(name EventName) {
	metricsMu.Lock()
	defer metricsMu.Unlock()
	getOrCreateMetric(name).PublishTotal++
}

func RecordFailed(name EventName) {
	metricsMu.Lock()
	defer metricsMu.Unlock()
	getOrCreateMetric(name).FailedTotal++
}

func RecordRetry(name EventName) {
	metricsMu.Lock()
	defer metricsMu.Unlock()
	getOrCreateMetric(name).RetryTotal++
}

func RecordDLQ(name EventName) {
	metricsMu.Lock()
	defer metricsMu.Unlock()
	getOrCreateMetric(name).DLQTotal++
}

func GetEventMetrics() map[EventName]EventMetrics {
	metricsMu.RLock()
	defer metricsMu.RUnlock()

	copyMetrics := make(map[EventName]EventMetrics)
	for k, v := range metrics {
		copyMetrics[k] = *v
	}
	return copyMetrics
}
