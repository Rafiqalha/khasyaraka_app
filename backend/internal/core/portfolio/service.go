package portfolio

import (
	"context"
	"encoding/json"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/evidence"
)

type EventName string

const (
	EventPortfolioProjected EventName = "portfolio.projected"
)

type Service interface {
	HandleEvidenceResolved(ctx context.Context, evt events.Event) error
}

type service struct {
	repo      Repository
	publisher events.Publisher
	curator   AutoCurator
}

func NewService(repo Repository, publisher events.Publisher, curator AutoCurator) Service {
	return &service{
		repo:      repo,
		publisher: publisher,
		curator:   curator,
	}
}

func (s *service) HandleEvidenceResolved(ctx context.Context, evt events.Event) error {
	var evd evidence.Evidence
	if err := json.Unmarshal(evt.Payload, &evd); err != nil {
		return err
	}

	// 1. Curate Evidence
	asset, err := s.curator.CurateEvidence(ctx, evt.Payload)
	if err != nil || asset == nil {
		return err // Maybe not high enough weight to curate
	}

	// 2. Create Candidate
	candidate := PortfolioCandidate{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		TriggerType:        "EVIDENCE_RESOLVED",
		TriggerRefID:       &evd.ID,
		KnowledgeLineageID: ulid.Make().String(), // Should pull from evd.KnowledgeLineageID if it existed
		EpochID:            "epoch_v1",           // Stand-in
		Payload:            evt.Payload,
		CreatedAt:          time.Now(),
	}
	if err := s.repo.SaveCandidate(ctx, candidate); err != nil {
		return err
	}

	// 3. Create Event (Source of Truth)
	assetJSON, _ := json.Marshal(asset)
	portEvent := PortfolioEvent{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		CandidateID:        &candidate.ID,
		KnowledgeLineageID: candidate.KnowledgeLineageID,
		EpochID:            candidate.EpochID,
		ActionType:         "ASSET_PUBLISHED",
		AssetID:            asset.AssetID,
		Payload:            assetJSON,
		CreatedAt:          time.Now(),
	}
	if err := s.repo.SaveEvent(ctx, portEvent); err != nil {
		return err
	}

	// 4. Project Showcase (Cache)
	// For MVP, just wrap the asset in an array
	proj := PortfolioProjection{
		ID:                 ulid.Make().String(),
		UserID:             evt.Metadata.UserID,
		KnowledgeLineageID: candidate.KnowledgeLineageID,
		EpochID:            candidate.EpochID,
		PublicShowcaseJSON: []byte(`[` + string(assetJSON) + `]`),
		Status:             "FRESH",
		ProjectedAt:        time.Now(),
	}
	if err := s.repo.SaveProjection(ctx, proj); err != nil {
		return err
	}

	// Emit Portfolio Projected
	projPayload, _ := json.Marshal(proj)
	s.publisher.Publish(ctx, events.Event{
		ID:            ulid.Make().String(),
		Name:          events.EventName(EventPortfolioProjected),
		Priority:      events.PriorityNormal,
		AggregateType: "PortfolioGraph",
		AggregateID:   proj.ID,
		Payload:       projPayload,
		Metadata:      evt.Metadata,
		OccurredAt:    time.Now(),
		SchemaVersion: "v1",
	})

	return nil
}
