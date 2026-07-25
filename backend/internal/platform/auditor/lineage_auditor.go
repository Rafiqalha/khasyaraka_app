package auditor

import (
	"context"
	"errors"
)

type LineageStatus string

const (
	LineageIntact LineageStatus = "INTACT"
	LineageBroken LineageStatus = "BROKEN LINEAGE"
)

type LineageAuditor interface {
	AuditProjection(ctx context.Context, projectionID string) (LineageStatus, error)
}

type auditor struct {
	// dependencies for traversing the graph backwards
}

func NewLineageAuditor() LineageAuditor {
	return &auditor{}
}

func (a *auditor) AuditProjection(ctx context.Context, projectionID string) (LineageStatus, error) {
	// For MVP, we pretend we traversed and everything is fine.
	// In reality:
	// 1. Fetch Projection -> get Contribution
	// 2. Fetch Contribution -> get Evidence
	// 3. Fetch Evidence -> get Observation
	// 4. Fetch Observation -> get Candidate
	// 5. Fetch Candidate -> get Aggregate
	// 6. Fetch Aggregate -> get Session/Activity
	// If any link returns sql.ErrNoRows -> return LineageBroken

	if projectionID == "" {
		return LineageBroken, errors.New("empty projection id")
	}

	return LineageIntact, nil
}
