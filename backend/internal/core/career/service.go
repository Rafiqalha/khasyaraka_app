package career

import (
	"context"
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/competency_graph"
	"github.com/pradigi/backend/internal/core/events"
)

type EventName string

const (
	EventCareerGapIdentified EventName = "career.gap.identified"
)

type Service interface {
	HandleCompetencyProjected(ctx context.Context, evt events.Event) error
}

type service struct {
	repo      Repository
	publisher events.Publisher
	analyzer  GapAnalyzer
}

func NewService(repo Repository, publisher events.Publisher, analyzer GapAnalyzer) Service {
	return &service{
		repo:      repo,
		publisher: publisher,
		analyzer:  analyzer,
	}
}

func (s *service) HandleCompetencyProjected(ctx context.Context, evt events.Event) error {
	var compProj competency_graph.CompetencyProjection
	if err := json.Unmarshal(evt.Payload, &compProj); err != nil {
		return err
	}

	// For MVP, we assume a static target role. Real system fetches user's target role.
	targetRoleID := "role_senior_backend"

	// 1. Analyze Gap
	gapResult, err := s.analyzer.AnalyzeGap(ctx, evt.Metadata.UserID, targetRoleID)
	if err != nil {
		return err
	}

	// 2. Create Candidate
	candidate := CareerCandidate{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		TriggerType:        "COMPETENCY_UPDATE",
		TriggerRefID:       &compProj.ID,
		KnowledgeLineageID: ulid.Make().String(),        // For MVP, generate if not passed
		EpochID:            compProj.GovernanceBundleID, // Stand-in for Epoch ID
		Payload:            evt.Payload,
		CreatedAt:          time.Now(),
	}
	if err := s.repo.SaveCandidate(ctx, candidate); err != nil {
		return err
	}

	// 3. Create Career Event (Source of Truth)
	gapJSON, _ := json.Marshal(gapResult.GapDetails)
	careerEvent := CareerEvent{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		CandidateID:        &candidate.ID,
		KnowledgeLineageID: candidate.KnowledgeLineageID,
		EpochID:            candidate.EpochID,
		ActionType:         "GAP_CALCULATED",
		TargetRoleID:       targetRoleID,
		Payload:            gapJSON,
		CreatedAt:          time.Now(),
	}
	if err := s.repo.SaveEvent(ctx, careerEvent); err != nil {
		return err
	}

	// 4. Project Readiness Cache
	proj := CareerProjection{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		TargetRoleID:       targetRoleID,
		KnowledgeLineageID: candidate.KnowledgeLineageID,
		EpochID:            candidate.EpochID,
		ReadinessScore:     gapResult.ReadinessScore,
		GapAnalysisJSON:    gapJSON,
		Status:             "FRESH",
		ProjectedAt:        time.Now(),
	}
	if err := s.repo.SaveProjection(ctx, proj); err != nil {
		return err
	}

	// Emit Gap Identified to trigger Roadmap Engine
	projPayload, _ := json.Marshal(proj)
	s.publisher.Publish(ctx, events.Event{
		ID:            ulid.Make().String(),
		Name:          events.EventName(EventCareerGapIdentified),
		Priority:      events.PriorityNormal,
		AggregateType: "CareerGraph",
		AggregateID:   proj.ID,
		Payload:       projPayload,
		Metadata:      evt.Metadata,
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	})

	return nil
}
