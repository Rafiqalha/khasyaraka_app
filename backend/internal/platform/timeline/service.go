package timeline

import (
	"context"
	"errors"
)

type Service interface {
	ExplainCapability(ctx context.Context, userID, skillNodeID string) (*Explanation, error)
	ExplainObservation(ctx context.Context, observationID string) (*Explanation, error)
	ExplainEvidence(ctx context.Context, evidenceID string) (*Explanation, error)
}

type service struct {
	// DB connection or repos to traverse the graph
}

func NewService() Service {
	return &service{}
}

func (s *service) ExplainCapability(ctx context.Context, userID, skillNodeID string) (*Explanation, error) {
	// 1. Fetch Capability Snapshot for user & skill
	// 2. Fetch Contributing Evidences
	// 3. Fetch Observations for those Evidences
	// 4. Fetch Candidates
	// 5. Build Graph (Nodes & Edges)
	return nil, errors.New("not implemented")
}

func (s *service) ExplainObservation(ctx context.Context, observationID string) (*Explanation, error) {
	return nil, errors.New("not implemented")
}

func (s *service) ExplainEvidence(ctx context.Context, evidenceID string) (*Explanation, error) {
	return nil, errors.New("not implemented")
}
