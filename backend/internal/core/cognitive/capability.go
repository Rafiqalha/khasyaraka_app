package cognitive

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// CapabilityDelta represents the multi-dimensional cognitive gain acquired from a validated learning episode.
// BOUNDARY RULE: Capability is not a flat single score; it decomposes into Confidence, Implementation, Debugging, and Reflection.
type CapabilityDelta struct {
	DeltaID          string  `json:"delta_id"`
	SessionID        string  `json:"session_id"`
	TargetCapability string  `json:"target_capability"`
	Confidence       float64 `json:"confidence"`
	Implementation   float64 `json:"implementation"`
	Debugging        float64 `json:"debugging"`
	Reflection       float64 `json:"reflection"`
}

const (
	EventCapabilityDeltaGenerated = "CapabilityDeltaGenerated"
)

// CapabilityEngine transforms qualitative evidence into multi-dimensional quantitative capability gains.
type CapabilityEngine struct {
	bus kernel.EventBus
}

func NewCapabilityEngine(bus kernel.EventBus) *CapabilityEngine {
	return &CapabilityEngine{bus: bus}
}

// OnEvent subscribes to EventEvidenceValidated emitted by EvidenceValidator.
func (c *CapabilityEngine) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != EventEvidenceValidated {
		return nil
	}

	var evd ValidatedEvidence
	if err := json.Unmarshal(event.Payload, &evd); err != nil {
		return fmt.Errorf("failed to unmarshal ValidatedEvidence in CapabilityEngine: %w", err)
	}

	logger.Info().Str("session", evd.SessionID).Str("capability", evd.TargetCapability).Msg("Capability Engine computing multidimensional delta")

	delta := &CapabilityDelta{
		DeltaID:          fmt.Sprintf("dlt_%d", time.Now().UnixNano()),
		SessionID:        evd.SessionID,
		TargetCapability: evd.TargetCapability,
	}

	switch evd.Signal {
	case SignalMastery:
		delta.Implementation = 0.12
		delta.Debugging = 0.15
		delta.Reflection = 0.20
		delta.Confidence = 0.10
	case SignalStruggle:
		delta.Implementation = 0.02
		delta.Debugging = 0.08
		delta.Reflection = 0.00
		delta.Confidence = -0.05
	case SignalExploration:
		delta.Implementation = 0.05
		delta.Debugging = 0.05
		delta.Reflection = 0.05
		delta.Confidence = 0.02
	default:
		// Zero gain for noise or unverified effort
		delta.Implementation = 0.0
		delta.Debugging = 0.0
		delta.Reflection = 0.0
		delta.Confidence = 0.0
	}

	logger.Info().
		Str("capability", delta.TargetCapability).
		Float64("impl", delta.Implementation).
		Float64("debug", delta.Debugging).
		Float64("reflect", delta.Reflection).
		Msg("Multidimensional capability delta computed -> Emitting to OS Event Bus")

	if c.bus != nil {
		payloadBytes, _ := json.Marshal(delta)
		busEvent := kernel.Event{
			ID:        fmt.Sprintf("evt_dlt_%d", time.Now().UnixNano()),
			SessionID: evd.SessionID,
			Type:      EventCapabilityDeltaGenerated,
			Source:    "capability_engine_multidimensional",
			Timestamp: time.Now(),
			Payload:   payloadBytes,
		}
		return c.bus.Publish(ctx, busEvent)
	}
	return nil
}
