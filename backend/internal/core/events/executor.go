package events

import (
	"context"
	"time"

	applogger "github.com/pradigi/backend/internal/pkg/logger"
)

type goroutineExecutor struct {
	retryStrategy RetryStrategy
	dlq           DLQ
}

func NewGoroutineExecutor(retryStrategy RetryStrategy, dlq DLQ) Executor {
	return &goroutineExecutor{
		retryStrategy: retryStrategy,
		dlq:           dlq,
	}
}

func (e *goroutineExecutor) Execute(ctx context.Context, handler Subscriber, event Event) {
	// Create a new context without cancelation for background task
	bgCtx := context.Background()

	go func() {
		defer func() {
			if r := recover(); r != nil {
				applogger.Error().
					Interface("panic", r).
					Str("event_id", event.ID).
					Str("event_name", string(event.Name)).
					Msg("panic in event handler")
			}
		}()

		var err error
		attempts := 0

		for {
			err = handler.Handle(bgCtx, event)
			if err == nil {
				return // Success
			}

			attempts++
			if e.retryStrategy != nil && e.retryStrategy.ShouldRetry(attempts, event) {
				RecordRetry(event.Name)
				delay := e.retryStrategy.NextDelay(attempts, event)
				time.Sleep(delay)
				continue
			}

			break // Exhausted retries
		}

		if err != nil {
			applogger.Error().
				Err(err).
				Str("event_id", event.ID).
				Str("event_name", string(event.Name)).
				Msg("error handling event, moving to DLQ")

			RecordFailed(event.Name)

			if e.dlq != nil {
				if pushErr := e.dlq.Push(bgCtx, event, err); pushErr != nil {
					applogger.Error().Err(pushErr).Msg("failed to push to DLQ")
				} else {
					RecordDLQ(event.Name)
				}
			}
		}
	}()
}
