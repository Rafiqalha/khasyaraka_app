package session

import (
	"context"
	"encoding/json"


	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/session/policies"
	"github.com/pradigi/backend/internal/platform/clock"
)

type Service interface {
	HandleLearningActivity(ctx context.Context, evt events.Event) error
	RebuildSession(ctx context.Context, userID string) error
}

type service struct {
	repo      Repository
	publisher events.Publisher
	policy    policies.Provider
	clock     clock.Clock
}

func NewService(repo Repository, publisher events.Publisher, pol policies.Provider, clk clock.Clock) Service {
	return &service{
		repo:      repo,
		publisher: publisher,
		policy:    pol,
		clock:     clk,
	}
}

// HandleLearningActivity infers session from a learning activity
func (s *service) HandleLearningActivity(ctx context.Context, evt events.Event) error {
	// 1. Get Active Session
	activeSession, err := s.repo.GetActiveSession(ctx, evt.Metadata.UserID)

	// In a real app, we handle sql.ErrNoRows cleanly, but assuming activeSession is nil if not found
	isNewSession := false
	policy := s.policy.GetPolicy(evt.Metadata.SourceEngine)
	if activeSession == nil || err != nil { // Simplified for MVP
		activeSession = &LearningSession{
			ID:          ulid.Make().String(),
			UserID:      evt.Metadata.UserID,
			TenantID:    evt.Metadata.TenantID,
			Status:      StatusActive,
			StartedAt:   evt.OccurredAt,
			DurationSec: 0,
		}
		isNewSession = true
		s.repo.CreateSession(ctx, *activeSession)
	} else {
		// Check Idle Timeout
		if evt.OccurredAt.Sub(activeSession.StartedAt) > policy.IdleTimeout { 
			// Close old session
			activeSession.Status = StatusEnded
			now := s.clock.Now()
			activeSession.EndedAt = &now
			s.repo.UpdateSession(ctx, *activeSession)
			
			// Publish ended
			s.publishSessionEvent(ctx, EventSessionEnded, *activeSession)

			// Create new session
			activeSession = &LearningSession{
				ID:          ulid.Make().String(),
				UserID:      evt.Metadata.UserID,
				TenantID:    evt.Metadata.TenantID,
				Status:      StatusActive,
				StartedAt:   evt.OccurredAt,
				DurationSec: 0,
			}
			isNewSession = true
			s.repo.CreateSession(ctx, *activeSession)
		}
	}

	if isNewSession {
		s.publishSessionEvent(ctx, EventSessionStarted, *activeSession)
	}

	// 2. Add Activity to Session
	sa := SessionActivity{
		SessionID:  activeSession.ID,
		ActivityID: evt.AggregateID,
		Sequence:   1, // Simplification for MVP, should be autoincrement or count
	}
	s.repo.AddActivityToSession(ctx, sa)

	return nil
}

func (s *service) RebuildSession(ctx context.Context, userID string) error {
	// Future implementation: Fetch all activities for user, apply Policy, rebuild learning_sessions and session_activities
	// Publish EventSessionRebuilt
	return nil
}

func (s *service) publishSessionEvent(ctx context.Context, eventName EventName, session LearningSession) {
	payload, _ := json.Marshal(session)
	evt := events.Event{
		ID:            ulid.Make().String(),
		Name:          events.EventName(eventName),
		Priority:      events.PriorityNormal,
		AggregateType: "Session",
		AggregateID:   session.ID,
		Payload:       payload,
		Metadata: events.Metadata{
			UserID:   session.UserID,
			TenantID: session.TenantID,
		},
		OccurredAt:    s.clock.Now(),
		SchemaVersion: "v1",
	}
	s.publisher.Publish(ctx, evt)
}
