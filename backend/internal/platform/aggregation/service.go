package aggregation

import (
	"context"
	"encoding/json"
	"sync"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/learning_activity"
	"github.com/pradigi/backend/internal/core/session"
)

type Service interface {
	HandleLearningActivity(ctx context.Context, evt events.Event) error
	HandleSessionEnded(ctx context.Context, evt events.Event) error
}

type service struct {
	publisher events.Publisher
	buffer    map[string]*ActivityAggregate // Key: sessionID
	mu        sync.RWMutex
}

func NewService(publisher events.Publisher) Service {
	return &service{
		publisher: publisher,
		buffer:    make(map[string]*ActivityAggregate),
	}
}

func (s *service) getOrCreateAggregate(sessionID, userID, tenantID string) *ActivityAggregate {
	s.mu.Lock()
	defer s.mu.Unlock()

	agg, exists := s.buffer[sessionID]
	if !exists {
		agg = &ActivityAggregate{
			SchemaVersion: "v1",
			SessionID:     sessionID,
			UserID:        userID,
			TenantID:      tenantID,
		}
		s.buffer[sessionID] = agg
	}
	return agg
}

func (s *service) HandleLearningActivity(ctx context.Context, evt events.Event) error {
	var activity learning_activity.LearningActivity
	if err := json.Unmarshal(evt.Payload, &activity); err != nil {
		return err
	}

	// For MVP, we need sessionID. If the Session Engine inferred it, it might not be in the LearningActivity payload.
	// In a fully decoupled flow, LearningActivity might not have sessionID.
	// But Aggregator consumes session.updated or relies on Session Engine to inject sessionID.
	// For simplicity, we assume we extract sessionID from another source, or we aggregate by UserID temporarily.
	// Ideally, Session Engine tags the Learning Activity with Session ID and re-publishes, or Aggregator reads from DB.
	
	// Let's assume evt.Metadata["SessionID"] is set by Session Engine before it reaches here.
	sessionID := evt.Metadata.SessionID 
	if sessionID == "" {
		// Fallback to UserID as temporary session grouping for MVP if not set
		sessionID = evt.Metadata.UserID
	}

	agg := s.getOrCreateAggregate(sessionID, evt.Metadata.UserID, evt.Metadata.TenantID)

	s.mu.Lock()
	defer s.mu.Unlock()

	switch activity.ActivityType {
	case learning_activity.ActivityTyping:
		agg.TypingCount++
		// If payload has characters: agg.TypingCharacters += len
	case learning_activity.ActivityAIAsk:
		agg.AIRequests++
	case learning_activity.ActivityRun:
		agg.CodeRuns++
	case learning_activity.ActivityCompile:
		// For MVP, parse payload to see if success or fail
		// agg.CompileSuccess++ or agg.CompileFailed++
	}

	return nil
}

func (s *service) HandleSessionEnded(ctx context.Context, evt events.Event) error {
	var sess session.LearningSession
	if err := json.Unmarshal(evt.Payload, &sess); err != nil {
		return err
	}

	s.mu.Lock()
	agg, exists := s.buffer[sess.ID]
	if exists {
		delete(s.buffer, sess.ID)
	}
	s.mu.Unlock()

	if !exists {
		return nil // No activities in this session
	}

	agg.Duration = sess.DurationSec

	payload, _ := json.Marshal(agg)
	pubEvent := events.Event{
		ID:            ulid.Make().String(),
		Name:          events.ActivityAggregated,
		Priority:      events.PriorityNormal,
		AggregateType: "ActivityAggregate",
		AggregateID:   agg.SessionID,
		Payload:       payload,
		Metadata: events.Metadata{
			UserID:    agg.UserID,
			TenantID:  agg.TenantID,
			SessionID: agg.SessionID,
		},
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	}

	s.publisher.Publish(ctx, pubEvent)
	return nil
}
