// Package behavior_modeling defines the Canonical Human Behavior Representation layer.
//
// This is the final deterministic abstraction before the LLM.
// It synthesizes temporal Cognitive Pattern Episodes into stable Behavior Profiles.
//
// Pipeline position:
//   Pattern Detector → Pattern Episodes → **Behavior Synthesizer** → Behavior Profile → Behavior Summary → LLM
package behavior_modeling

import (
	"time"

	"github.com/pradigi/backend/internal/core/cognitive_pattern"
)

// ===========================
// Behavior Window (Temporal Scope)
// ===========================

type BehaviorWindow string

const (
	WindowMission  BehaviorWindow = "MISSION"
	WindowWeek     BehaviorWindow = "WEEK"
	WindowMonth    BehaviorWindow = "MONTH"
	WindowLifetime BehaviorWindow = "LIFETIME"
)

// ===========================
// Behavior Evidence
// Every trait must point back to the patterns that formed it.
// ===========================

type BehaviorEvidence struct {
	PatternType        cognitive_pattern.PatternType `json:"pattern_type"`
	PatternEpisodeIDs  []string                      `json:"pattern_episode_ids"` // References CognitivePattern.ID
	Weight             float64                       `json:"weight"`              // How much this pattern contributed
	Description        string                        `json:"description"`         // "Frequent rapid retries after errors"
}

// ===========================
// Behavior Trait
// A specific behavioral characteristic with confidence and evidence.
// ===========================

type BehaviorTrait[T any] struct {
	Value      T                  `json:"value"`
	Confidence float64            `json:"confidence"`
	Stability  float64            `json:"stability"` // How consistent this is over time (0.0 - 1.0)
	Evidence   []BehaviorEvidence `json:"evidence"`
}

// ===========================
// Strategy Distribution
// Strategies are not single enums, but a probability distribution.
// e.g. Systematic: 0.7, TrialAndError: 0.3
// ===========================

type StrategyType string

const (
	StrategySystematic  StrategyType = "SYSTEMATIC"
	StrategyTrialError  StrategyType = "TRIAL_AND_ERROR"
	StrategyBottomUp    StrategyType = "BOTTOM_UP"
	StrategyTopDown     StrategyType = "TOP_DOWN"
	StrategyDivide      StrategyType = "DIVIDE_AND_CONQUER"
)

type StrategyDistribution map[StrategyType]float64

// ===========================
// Dimensions (Baseline vs Current)
// ===========================

// BehaviorDimensions compares the current session against historical baseline.
type BehaviorDimensions struct {
	Current  BehaviorTrait[string] `json:"current"`  // State in the current window (e.g. Mission)
	Baseline BehaviorTrait[string] `json:"baseline"` // Historical norm (e.g. Lifetime/Month)
}

// StrategyDimensions compares strategy distributions.
type StrategyDimensions struct {
	Current  BehaviorTrait[StrategyDistribution] `json:"current"`
	Baseline BehaviorTrait[StrategyDistribution] `json:"baseline"`
}

// ===========================
// Behavior Diff (Evolution tracking)
// ===========================

type TraitDiff struct {
	PreviousValue string  `json:"previous_value"`
	CurrentValue  string  `json:"current_value"`
	ChangeMetric  float64 `json:"change_metric,omitempty"` // For numeric/probabilistic traits
}

type BehaviorDiff struct {
	AIDependencyShift TraitDiff `json:"ai_dependency_shift"`
	PersistenceShift  TraitDiff `json:"persistence_shift"`
	StrategyShift     TraitDiff `json:"strategy_shift"`
}

// ===========================
// Behavior Profile (The Canonical Representation)
// Versioned, Fingerprinted, and Deterministic.
// ===========================

type BehaviorProfile struct {
	ID                   string         `json:"id"`
	UserID               string         `json:"user_id"`
	SessionID            string         `json:"session_id,omitempty"` // Included if window is MISSION
	Window               BehaviorWindow `json:"window"`
	
	// Deterministic Identity
	Version              int       `json:"version"`                 // Auto-increments: v14 -> v15
	ParentProfileID      string    `json:"parent_profile_id"`       // Links to v14
	SynthesizerVersion   string    `json:"synthesizer_version"`     // e.g., "v1.2.0" - rules used to build this
	Fingerprint          string    `json:"fingerprint"`             // Hash(Episodes + SynthVersion + Window)
	GeneratedAt          time.Time `json:"generated_at"`

	// Behavioral Traits (Dual Dimension: Current vs Baseline)
	Persistence          BehaviorDimensions `json:"persistence"`          // High, Medium, Low
	AIDependency         BehaviorDimensions `json:"ai_dependency"`        // High, Low
	RecoveryCapability   BehaviorDimensions `json:"recovery_capability"`  // Excellent, Poor
	Strategies           StrategyDimensions `json:"strategies"`

	// Evolution
	RecentEvolution      *BehaviorDiff      `json:"recent_evolution,omitempty"`
}

// ===========================
// Behavior Summary (For the LLM)
// A highly compressed, dense context payload.
// ===========================

// BehaviorSummary is what actually gets sent to Reasoning OS (via Mission Summary / Observation Candidate).
// It converts complex distributions and evidence into natural language constraints and highlights.
type BehaviorSummary struct {
	PrimaryStrategy      string  `json:"primary_strategy"`       // The dominant strategy (e.g. "Systematic Debugging")
	StrategyConfidence   float64 `json:"strategy_confidence"`    
	
	// Anomalies / Delta from baseline
	AnomalyHighlights    []string `json:"anomaly_highlights"`     // e.g. ["Usually Systematic (0.8), but currently TrialAndError (0.7)"]
	
	// Key Traits
	PersistenceLevel     string  `json:"persistence_level"`      // "High"
	AIDependencyLevel    string  `json:"ai_dependency_level"`    // "Low"
	RecoveryCapability   string  `json:"recovery_capability"`    // "Excellent"
	
	// Contextual guidance for the LLM
	LLMContextGuidance   string  `json:"llm_context_guidance"`   // e.g. "User is panicking. Provide emotional scaffolding before technical hints."
	
	// Narrative (Top-level summary)
	BehaviorNarrative    string  `json:"behavior_narrative"`     // "Pengguna menunjukkan pola debugging berbasis hipotesis..."
}
