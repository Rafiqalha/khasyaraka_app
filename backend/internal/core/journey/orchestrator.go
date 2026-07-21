package journey

import (
	"errors"
	"time"

	"github.com/oklog/ulid/v2"
)

// Orchestrator handles progression logic for a Learning Journey.
type Orchestrator struct {
	// In a real implementation, this would use a repository to append events.
	events []JourneyEvent
}

func NewOrchestrator() *Orchestrator {
	return &Orchestrator{
		events: make([]JourneyEvent, 0),
	}
}

// StartJourney creates a new journey and unlocks the first node.
func (o *Orchestrator) StartJourney(userID, curriculumID, firstNodeID string) (*Journey, error) {
	journeyID := ulid.Make().String()
	
	o.appendEvent(JourneyEvent{
		JourneyID: journeyID,
		Type:      EventJourneyStarted,
		Payload:   `{"curriculum_id": "` + curriculumID + `"}`,
	})

	o.appendEvent(JourneyEvent{
		JourneyID: journeyID,
		NodeID:    &firstNodeID,
		Type:      EventNodeUnlocked,
	})

	return o.Project(journeyID)
}

// ProcessNodeAction transitions a node's state (start, pause, complete).
func (o *Orchestrator) ProcessNodeAction(journeyID, nodeID string, action EventType) (*Journey, error) {
	// Validate action
	switch action {
	case EventNodeStarted, EventNodePaused, EventNodeResumed, EventNodeCompleted:
		// Valid actions
	default:
		return nil, errors.New("invalid node action")
	}

	o.appendEvent(JourneyEvent{
		JourneyID: journeyID,
		NodeID:    &nodeID,
		Type:      action,
	})

	// If completed, business logic would dictate unlocking the next node.
	// That requires access to the Curriculum manifest to find the next node.
	// For this slice, we omit the curriculum lookup here, assuming a higher-level Service coordinates it.

	return o.Project(journeyID)
}

func (o *Orchestrator) UnlockNode(journeyID, nodeID string) {
	o.appendEvent(JourneyEvent{
		JourneyID: journeyID,
		NodeID:    &nodeID,
		Type:      EventNodeUnlocked,
	})
}

// Project builds the Journey state from events.
func (o *Orchestrator) Project(journeyID string) (*Journey, error) {
	journey := &Journey{
		ID:     journeyID,
		Status: "ACTIVE",
		Nodes:  make(map[string]NodeState),
	}

	for _, e := range o.events {
		if e.JourneyID != journeyID {
			continue
		}

		if e.Type == EventJourneyStarted {
			journey.CreatedAt = e.Timestamp
			journey.UpdatedAt = e.Timestamp
		}

		if e.NodeID != nil {
			nodeID := *e.NodeID
			state, ok := journey.Nodes[nodeID]
			if !ok {
				state = NodeState{NodeID: nodeID, Status: "LOCKED"}
			}

			switch e.Type {
			case EventNodeUnlocked:
				state.Status = "UNLOCKED"
			case EventNodeStarted, EventNodeResumed:
				state.Status = "STARTED"
				journey.ActiveNodeID = nodeID
			case EventNodePaused:
				state.Status = "PAUSED"
			case EventNodeCompleted:
				state.Status = "COMPLETED"
			}
			journey.Nodes[nodeID] = state
		}
	}

	return journey, nil
}

func (o *Orchestrator) appendEvent(e JourneyEvent) {
	if e.ID == "" {
		e.ID = ulid.Make().String()
	}
	e.Timestamp = time.Now()
	o.events = append(o.events, e)
}
