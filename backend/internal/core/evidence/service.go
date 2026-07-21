package evidence

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
)

type EventName string

const (
	EventObservationAccepted EventName = "observation.accepted"
	EventEvidenceResolved    EventName = "evidence.resolved"
)

type Service interface {
	HandleObservationAccepted(ctx context.Context, evt events.Event) error
}

type service struct {
	repo      Repository
	publisher events.Publisher
	// Extractor and Governance Policy could be dependencies
}

func NewService(repo Repository, publisher events.Publisher) Service {
	return &service{
		repo:      repo,
		publisher: publisher,
	}
}

// In real app, Observation struct is passed via Payload
type ObsPayload struct {
	ID                   string
	ExecutionFingerprint string
	Skills               []struct {
		SkillID   string
		Direction string
		Strength  float64
		Reason    string
	}
}

func (s *service) HandleObservationAccepted(ctx context.Context, evt events.Event) error {
	var obs ObsPayload
	if err := json.Unmarshal(evt.Payload, &obs); err != nil {
		return err
	}

	var resolvedEvidences []Evidence

	for _, skill := range obs.Skills {
		// 1. Fingerprint Calculation (Idempotent replay)
		// Based on Observation Exec FP + Extractor Version + Policy Version
		fpData := fmt.Sprintf("%s|%s|%s", obs.ExecutionFingerprint, "ext_v1", "pol_v1")
		hash := sha256.Sum256([]byte(fpData))
		fp := hex.EncodeToString(hash[:])

		// 2. Extractor mapping (Mocking Skill string to Node ID)
		skillNodeID := "node_" + skill.SkillID // mock
		
		// 3. Create Evidence in GENERATED state
		validityEnd := time.Now().AddDate(0, 6, 0) // Valid for 6 months
		ev := Evidence{
			ID:            ulid.Make().String(),
			ObservationID: obs.ID,
			SkillNodeID:   &skillNodeID,
			EvidenceType:  "Performance", // derived from Governance rules
			Status:        StatusGenerated,
			Fingerprint:   fp,
			Direction:     skill.Direction,
			Strength:      skill.Strength,
			Reason:        skill.Reason,
			ValidityEndAt: &validityEnd,
			Weight:        1.0,
			CreatedAt:     time.Now(),
		}
		
		// 4. In reality, check for duplicates (Deduplication using Fingerprint)
		// For MVP, just save it.
		
		// 5. Run Conflict Resolution (Mocking as PASS)
		ev.Status = StatusResolved

		if err := s.repo.SaveEvidence(ctx, ev); err != nil {
			return err
		}
		resolvedEvidences = append(resolvedEvidences, ev)
	}

	// 6. Publish Evidence Resolved
	for _, rev := range resolvedEvidences {
		payload, _ := json.Marshal(rev)
		pubEvent := events.Event{
			ID:            ulid.Make().String(),
			Name:          events.EventName(EventEvidenceResolved),
			Priority:      events.PriorityNormal,
			AggregateType: "Evidence",
			AggregateID:   rev.ID,
			Payload:       payload,
			Metadata: events.Metadata{
				UserID:       evt.Metadata.UserID,
				TenantID:     evt.Metadata.TenantID,
				SessionID:    evt.Metadata.SessionID,
				SourceEngine: "evidence",
			},
			OccurredAt:    time.Now(),
			SchemaVersion: "v1",
		}
		s.publisher.Publish(ctx, pubEvent)
	}

	return nil
}
