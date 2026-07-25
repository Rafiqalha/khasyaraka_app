package observation

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/pkg/ai"
)

type Service interface {
	HandleActivityAggregated(ctx context.Context, evt events.Event) error
}

type service struct {
	repo      Repository
	publisher events.Publisher
	aiClient  ai.Client
	validator Validator
}

func NewService(repo Repository, publisher events.Publisher, aiClient ai.Client, val Validator) Service {
	return &service{
		repo:      repo,
		publisher: publisher,
		aiClient:  aiClient,
		validator: val,
	}
}

func (s *service) HandleActivityAggregated(ctx context.Context, evt events.Event) error {
	// 1. Candidate Generation & Input Fingerprint
	inputFpData := fmt.Sprintf("%s|%s", evt.AggregateID, evt.Metadata.SessionID) // simplified
	inputHash := sha256.Sum256([]byte(inputFpData))
	inputFingerprint := hex.EncodeToString(inputHash[:])

	candidate := ObservationCandidate{
		ID:          ulid.Make().String(),
		SessionID:   evt.Metadata.SessionID,
		Fingerprint: inputFingerprint,
		CreatedAt:   time.Now(),
	}
	if err := s.repo.SaveCandidate(ctx, candidate); err != nil {
		return err
	}

	// 2. Fetch PromptBundle (mocking v1)
	bundle, err := s.repo.GetPromptBundle(ctx, "obs-bundle", "v1")
	if err != nil || bundle == nil {
		bundle = &PromptBundle{
			ID:        ulid.Make().String(),
			Name:      "obs-bundle",
			Version:   "v1",
			Hash:      "dummyhash",
			CreatedAt: time.Now(),
		}
		s.repo.SavePromptBundle(ctx, *bundle)
	}

	// 3. AI Inference
	promptString := fmt.Sprintf("Analyze this candidate: %s", candidate.ID)
	aiResp, err := s.aiClient.Generate(ctx, promptString)
	if err != nil {
		return err
	}

	// 4. Validation Chain
	valCtx := &ValidationContext{
		ObservationID: ulid.Make().String(),
		RawOutput:     aiResp.Raw,
	}

	err = s.validator.Validate(valCtx)

	status := "VALIDATED"
	if err != nil {
		status = "GENERATED" // Didn't pass validation
	}

	// Save Validation Reports
	for _, report := range valCtx.Reports {
		s.repo.SaveValidationReport(ctx, report)
	}

	if err != nil {
		return err // In reality, trigger replay/retry
	}

	// 5. Execution Fingerprint
	execFpData := fmt.Sprintf("%s|%s|%s", bundle.Hash, aiResp.Model, "chain_v1")
	execHash := sha256.Sum256([]byte(execFpData))
	execFingerprint := hex.EncodeToString(execHash[:])

	// 6. Save Observation
	prov := Provenance{
		SourceSessionID: candidate.SessionID,
		CandidateID:     candidate.ID,
	}
	provBytes, _ := json.Marshal(prov)
	usageBytes, _ := json.Marshal(aiResp.Usage)

	obs := Observation{
		ID:                   valCtx.ObservationID,
		CandidateID:          candidate.ID,
		PromptBundleID:       bundle.ID,
		ModelID:              "model_1", // Mock
		InferenceProfileID:   "prof_1",  // Mock
		InputFingerprint:     inputFingerprint,
		ExecutionFingerprint: execFingerprint,
		Status:               status,
		ObservationType:      "GENERAL",
		Confidence:           valCtx.ParsedOutput.Confidence,
		ObservationQuality:   0.9,
		Summary:              valCtx.ParsedOutput.Summary,
		AILatencyMs:          aiResp.Latency.Milliseconds(),
		AICost:               aiResp.Cost,
		AIUsageJSON:          usageBytes,
		AIRequestID:          aiResp.RequestID,
		ProvenanceJSON:       provBytes,
		Provenance:           prov,
		CreatedAt:            time.Now(),
	}

	if err := s.repo.SaveObservation(ctx, obs); err != nil {
		return err
	}

	// 7. Publish Domain Event
	payload, _ := json.Marshal(obs)
	pubEvent := events.Event{
		ID:            ulid.Make().String(),
		Name:          events.EventName("observation.accepted"), // Should match evidence engine subscription
		Priority:      events.PriorityNormal,
		AggregateType: "Observation",
		AggregateID:   obs.ID,
		Payload:       payload, // Wait, payload should ideally be the Observation struct, but Evidence Engine expects ObsPayload.
		// Actually Evidence Engine expects the skills list, let's inject it into payload for MVP.
		Metadata: events.Metadata{
			UserID:       evt.Metadata.UserID,
			TenantID:     evt.Metadata.TenantID,
			SessionID:    candidate.SessionID,
			SourceEngine: "observation",
		},
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	}

	// Hack for MVP to pass skills to evidence engine
	type obsPayload struct {
		ID                   string
		ExecutionFingerprint string
		Skills               interface{}
	}
	op := obsPayload{
		ID:                   obs.ID,
		ExecutionFingerprint: obs.ExecutionFingerprint,
		Skills:               valCtx.ParsedOutput.Skills,
	}
	pubEvent.Payload, _ = json.Marshal(op)

	s.publisher.Publish(ctx, pubEvent)

	return nil
}
