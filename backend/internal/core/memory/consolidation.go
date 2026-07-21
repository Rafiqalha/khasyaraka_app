package memory

import "context"

type ConsolidationStrategy interface {
	Consolidate(ctx context.Context, candidate MemoryCandidate, existingEvents []MemoryEvent) (*MemoryEvent, bool)
}

type basicConsolidation struct {}

func NewConsolidationStrategy() ConsolidationStrategy {
	return &basicConsolidation{}
}

func (s *basicConsolidation) Consolidate(ctx context.Context, candidate MemoryCandidate, existingEvents []MemoryEvent) (*MemoryEvent, bool) {
	// Simple MVP Consolidation:
	// If we find an existing MemoryEvent with the exact same memory_type and similar payload
	// within the last 24 hours, we consolidate by returning the existing event ID with boosted strength,
	// rather than creating a completely new event.
	
	// For MVP, if there are existing events, just pick the first one and boost it (simulate consolidation)
	if len(existingEvents) > 0 {
		evt := existingEvents[0]
		evt.Strength += 0.5 // Boost strength
		return &evt, true   // true = consolidated
	}
	
	// Return nil if no consolidation happened
	return nil, false
}
