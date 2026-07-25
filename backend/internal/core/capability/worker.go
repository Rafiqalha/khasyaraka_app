package capability

import (
	"context"

	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"

	"github.com/pradigi/backend/internal/core/events"
	applogger "github.com/pradigi/backend/internal/pkg/logger"
)

type Worker struct {
	repo      Repository
	extractor FeatureExtractor
	evaluator Evaluator
	publisher events.Publisher
	eventChan chan EvaluationEvent
}

func NewWorker(repo Repository, extractor FeatureExtractor, evaluator Evaluator, publisher events.Publisher) *Worker {
	return &Worker{
		repo:      repo,
		extractor: extractor,
		evaluator: evaluator,
		publisher: publisher,
		eventChan: make(chan EvaluationEvent, 100), // Simple in-memory buffer
	}
}

// SubmitEvent allows other engines (like Mission Engine) to submit events asynchronously.
func (w *Worker) SubmitEvent(event EvaluationEvent) {
	w.eventChan <- event
}

// Start begins the background processing of capability events.
func (w *Worker) Start(ctx context.Context) {
	logger := applogger.Get()
	logger.Info().Msg("Capability Engine Worker started")

	for {
		select {
		case <-ctx.Done():
			logger.Info().Msg("Capability Engine Worker stopped")
			return
		case event := <-w.eventChan:
			w.processEvent(event)
		}
	}
}

func (w *Worker) processEvent(event EvaluationEvent) {
	logger := applogger.Get()

	// 1. Feature Extraction
	features, err := w.extractor.Extract(event)
	if err != nil {
		logger.Error().Err(err).Msg("failed to extract features from event")
		return
	}

	if len(features) == 0 {
		return // Nothing to evaluate
	}

	// 2. Fetch current capabilities for this user
	currentCaps, err := w.repo.GetUserCapabilities(event.UserID)
	if err != nil {
		logger.Error().Err(err).Msg("failed to fetch user capabilities")
		return
	}

	// Because Evaluator expects []LearnerCapability, we map the response
	var currentLearnerCaps []LearnerCapability
	for _, c := range currentCaps {
		currentLearnerCaps = append(currentLearnerCaps, LearnerCapability{
			UserID:           event.UserID,
			SkillID:          c.SkillID,
			ProficiencyScore: c.ProficiencyScore,
			EvidenceScore:    c.EvidenceScore,
		})
	}

	// 3. Evaluation via AI / Rule Engine
	updates, err := w.evaluator.Evaluate(features, currentLearnerCaps)
	if err != nil {
		logger.Error().Err(err).Msg("failed to evaluate features")
		return
	}

	// 4. Update Capabilities & Log
	for _, update := range updates {
		// Calculate new score based on delta
		newScore := update.DeltaScore

		err := w.repo.UpsertCapability(&LearnerCapability{
			UserID:           event.UserID,
			SkillID:          update.SkillID,
			ProficiencyScore: newScore, // In real implementation, this would be current + delta
			EvidenceScore:    0.5,      // Mock evidence update
		})

		if err == nil {
			// 5. Publish to Event Engine
			payload, _ := json.Marshal(map[string]interface{}{
				"user_id":   event.UserID,
				"skill_id":  update.SkillID,
				"delta":     update.DeltaScore,
				"new_score": newScore,
				"old_score": newScore - update.DeltaScore, // Simplification for now
			})

			pubEvent := events.Event{
				ID:            ulid.Make().String(),
				Name:          events.CapabilityUpdated,
				Priority:      events.PriorityHigh,
				AggregateType: "Capability",
				AggregateID:   event.UserID + ":" + update.SkillID,
				Payload:       payload,
				Metadata: events.Metadata{
					UserID:       event.UserID,
					SourceEngine: "CapabilityEngine",
				},
				OccurredAt:    time.Now(),
				SchemaVersion: "v1",
			}

			w.publisher.Publish(context.Background(), pubEvent)

			logger.Info().
				Str("user_id", event.UserID).
				Str("skill_id", update.SkillID).
				Int("delta", update.DeltaScore).
				Msg("Capability updated and published")
		}
	}
}
