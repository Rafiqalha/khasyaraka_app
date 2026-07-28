package cognitive

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

type CognitiveSignal string

const (
	SignalMastery     CognitiveSignal = "MASTERY"
	SignalStruggle    CognitiveSignal = "STRUGGLE"
	SignalExploration CognitiveSignal = "EXPLORATION"
	SignalGuessing    CognitiveSignal = "GUESSING"
	SignalCopying     CognitiveSignal = "COPYING"
	SignalAbandoned   CognitiveSignal = "ABANDONED"
)

const (
	EventEvidenceValidated = "CognitiveEvidenceValidated"
	EventEvidenceRejected  = "CognitiveEvidenceRejected"
)

// ValidatedEvidence represents high-signal proof of learning after filtering out cognitive noise and gaming.
type ValidatedEvidence struct {
	EvidenceID       string          `json:"evidence_id"`
	EpisodeID        string          `json:"episode_id"`
	SessionID        string          `json:"session_id"`
	TargetCapability string          `json:"target_capability"`
	QualityScore     float64         `json:"quality_score"` // 0.05 to 0.95
	Signal           CognitiveSignal `json:"signal"`        // MASTERY, COPYING, etc.
	Status           string          `json:"status"`        // ACCEPTED or REJECTED
	Reason           string          `json:"reason"`
}

// EvidenceValidator acts as the gatekeeper between Cognitive Episodes and Capability Delta.
// BOUNDARY RULE: Prevents cognitive gaming (e.g., copy-paste spam, compile spam) from polluting the Capability Engine.
type EvidenceValidator struct {
	bus kernel.EventBus
}

func NewEvidenceValidator(bus kernel.EventBus) *EvidenceValidator {
	return &EvidenceValidator{bus: bus}
}

// OnEvent subscribes to EventEpisodeCompleted emitted by the EpisodeBuilder.
func (v *EvidenceValidator) OnEvent(ctx context.Context, event kernel.Event) error {
	if event.Type != EventEpisodeCompleted {
		return nil
	}

	var ep CognitiveEpisode
	if err := json.Unmarshal(event.Payload, &ep); err != nil {
		return fmt.Errorf("failed to unmarshal CognitiveEpisode in EvidenceValidator: %w", err)
	}

	logger.Info().Str("session", ep.SessionID).Str("episode", ep.EpisodeID).Msg("Evidence Validator evaluating cognitive trajectory")

	evidence := v.ValidateEpisode(&ep)

	var eventType string
	if evidence.Status == "ACCEPTED" {
		eventType = EventEvidenceValidated
	} else {
		eventType = EventEvidenceRejected
	}

	logger.Info().
		Str("session", ep.SessionID).
		Str("signal", string(evidence.Signal)).
		Float64("score", evidence.QualityScore).
		Str("status", evidence.Status).
		Msg("Cognitive Evidence evaluation complete -> Emitting to OS Event Bus")

	if v.bus != nil {
		payloadBytes, _ := json.Marshal(evidence)
		busEvent := kernel.Event{
			ID:        fmt.Sprintf("evt_evd_%d", time.Now().UnixNano()),
			SessionID: ep.SessionID,
			Type:      eventType,
			Source:    "evidence_validator_gatekeeper",
			Timestamp: time.Now(),
			Payload:   payloadBytes,
		}
		return v.bus.Publish(ctx, busEvent)
	}
	return nil
}

// ValidateEpisode applies deterministic cognitive heuristics to evaluate learning quality.
func (v *EvidenceValidator) ValidateEpisode(ep *CognitiveEpisode) *ValidatedEvidence {
	evd := &ValidatedEvidence{
		EvidenceID:       fmt.Sprintf("evd_%d", time.Now().UnixNano()),
		EpisodeID:        ep.EpisodeID,
		SessionID:        ep.SessionID,
		TargetCapability: ep.TargetCapability,
	}

	// Rule 1: Copy-Paste Gaming / Copy Dominant
	if ep.PasteCount >= 2 && ep.EditCount < 2 {
		evd.Signal = SignalCopying
		evd.QualityScore = 0.18
		evd.Status = "REJECTED"
		evd.Reason = "Copy Dominant: excessive pasting without original editing"
		return evd
	}

	// Rule 2: Compile Spam / Guessing without comprehension
	if ep.CompileCount >= 4 && ep.TestPassCount == 0 {
		evd.Signal = SignalGuessing
		evd.QualityScore = 0.30
		evd.Status = "REJECTED"
		evd.Reason = "Guessing Spam: repeated compile attempts without passing tests or reflection"
		return evd
	}

	// Rule 3: Debugging perseverance with Reflection -> True Cognitive Mastery!
	if ep.TestFailCount > 0 && ep.TestPassCount > 0 && ep.ReflectionSubmitted {
		evd.Signal = SignalMastery
		evd.QualityScore = 0.91
		evd.Status = "ACCEPTED"
		evd.Reason = "Mastery Proven: successful debugging trajectory coupled with reflection"
		return evd
	}

	// Rule 4: Clean Code Execution Mastery
	if ep.TestPassCount > 0 && ep.EditCount > 0 {
		evd.Signal = SignalMastery
		evd.QualityScore = 0.85
		evd.Status = "ACCEPTED"
		evd.Reason = "Mastery Proven: original editing leading to test success"
		return evd
	}

	// Rule 5: Struggle (High effort, no pass yet -> Planner will scaffold next time)
	if ep.EditCount >= 3 && ep.TestFailCount >= 2 {
		evd.Signal = SignalStruggle
		evd.QualityScore = 0.55
		evd.Status = "ACCEPTED"
		evd.Reason = "Struggle Detected: high editing and debug effort; requires scaffold hint"
		return evd
	}

	// Default: Standard Exploration
	evd.Signal = SignalExploration
	evd.QualityScore = 0.50
	evd.Status = "ACCEPTED"
	evd.Reason = "Standard exploration trajectory"
	return evd
}
