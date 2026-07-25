// Package cognitive_pattern defines the Cognitive Pattern Engine.
//
// This is a CORE domain — NOT part of Workbench.
// It sits between raw Learning Activities and Reasoning OS.
//
// Purpose:
//
//	LLM does NOT see 300 raw events.
//	LLM sees: [RepeatedExecutionPattern, ErrorDrivenIteration, HintCopyBehavior]
//
// All patterns are DETERMINISTIC. No AI. No LLM.
// Patterns are extracted from event sequences using finite rules.
//
// Pipeline position:
//
//	Learning Activity → Decision Graph → **Cognitive Pattern Engine** → Mission Summary → Observation Candidate → Reasoning OS
package cognitive_pattern

import "time"

// ===========================
// Cognitive Pattern (The Core Abstraction)
// A pattern is a named, deterministic summary of a behavioral sequence.
// It is NOT an opinion. It is a measured signal.
// ===========================

type PatternType string

const (
	// Execution Patterns
	PatternRepeatedExecution PatternType = "REPEATED_EXECUTION" // Run Run Run Run
	PatternRapidRetry        PatternType = "RAPID_RETRY"        // Run → Fail → Run → Fail (< 10s intervals)
	PatternSlowIteration     PatternType = "SLOW_ITERATION"     // Run → long pause → Run

	// Error Handling Patterns
	PatternErrorDrivenIteration PatternType = "ERROR_DRIVEN_ITERATION" // Read Error → Edit → Run
	PatternErrorIgnored         PatternType = "ERROR_IGNORED"          // Error produced but no edit follows
	PatternStackTraceNavigation PatternType = "STACK_TRACE_NAVIGATION" // Open error → Jump to line → Edit

	// AI Interaction Patterns
	PatternHintCopy           PatternType = "HINT_COPY_BEHAVIOR"  // Ask Mentor → Copy → Paste → Run
	PatternHintIgnored        PatternType = "HINT_IGNORED"        // Ask Mentor → no change → Run
	PatternProgressiveHinting PatternType = "PROGRESSIVE_HINTING" // Ask Mentor → partial apply → Ask again
	PatternAIDependency       PatternType = "AI_DEPENDENCY"       // Frequent AI calls relative to own attempts

	// Strategy Patterns
	PatternSystematicDebugging PatternType = "SYSTEMATIC_DEBUGGING" // Hypothesis → Test → Observe → Revise
	PatternTrialAndError       PatternType = "TRIAL_AND_ERROR"      // Random edits → Run → repeat
	PatternDivideAndConquer    PatternType = "DIVIDE_AND_CONQUER"   // Isolate → Test subset → Narrow
	PatternBottomUp            PatternType = "BOTTOM_UP"            // Fix small → build up
	PatternTopDown             PatternType = "TOP_DOWN"             // Understand whole → fix specific

	// Recovery Patterns
	PatternRecoveryAfterBlock PatternType = "RECOVERY_AFTER_BLOCK" // Blocked → AI/Docs → Progress
	PatternPersistence        PatternType = "PERSISTENCE"          // Many failures but continues
	PatternEarlyAbandon       PatternType = "EARLY_ABANDON"        // Few attempts → Abandon

	// Artifact Patterns
	PatternIncrementalRefinement PatternType = "INCREMENTAL_REFINEMENT" // v1 → v2 → v3 (small diffs)
	PatternBigBangRewrite        PatternType = "BIG_BANG_REWRITE"       // v1 → v2 (complete rewrite)
)

// CognitivePattern is a single detected pattern instance.
type CognitivePattern struct {
	ID          string      `json:"id"`
	SessionID   string      `json:"session_id"`
	PatternType PatternType `json:"pattern_type"`

	// Evidence: the event IDs that form this pattern
	SourceEventIDs []string `json:"source_event_ids"`

	// Quantitative measurements
	Frequency       int     `json:"frequency"`        // How many times this pattern occurred
	AverageInterval float64 `json:"average_interval"` // Seconds between pattern occurrences
	Confidence      float64 `json:"confidence"`       // 0.0–1.0 how strongly the data supports this pattern
	Duration        float64 `json:"duration_seconds"` // Total time span of this pattern

	// Context
	StartedAt time.Time `json:"started_at"`
	EndedAt   time.Time `json:"ended_at"`
}

// ===========================
// Semantic Decision Graph (Level 2 Abstraction)
// Raw graph: Read Error → Ask Mentor → Run → Run
// Semantic graph: Explore → Hypothesis → Validate → Recover
// ===========================

type CognitiveIntent string

const (
	IntentExplore    CognitiveIntent = "EXPLORE"
	IntentValidate   CognitiveIntent = "VALIDATE"
	IntentOptimize   CognitiveIntent = "OPTIMIZE"
	IntentRecover    CognitiveIntent = "RECOVER"
	IntentUnderstand CognitiveIntent = "UNDERSTAND"
	IntentMemorize   CognitiveIntent = "MEMORIZE"
	IntentGeneralize CognitiveIntent = "GENERALIZE"

	// Legacy mappings for backwards compatibility or specific actions
	IntentHypothesis CognitiveIntent = "HYPOTHESIS"
	IntentFailure    CognitiveIntent = "FAILURE"
	IntentDelegation CognitiveIntent = "DELEGATION"
)

type SemanticNode struct {
	ID                string          `json:"id"`
	SessionID         string          `json:"session_id"`
	NodeType          CognitiveIntent `json:"node_type"`
	SourceActivityIDs []string        `json:"source_activity_ids"` // Which raw activities form this node
	Summary           string          `json:"summary"`             // "User hypothesized off-by-one error"
	OccurredAt        time.Time       `json:"occurred_at"`
}

type SemanticEdge struct {
	FromNodeID string `json:"from_node_id"`
	ToNodeID   string `json:"to_node_id"`
	Relation   string `json:"relation"` // "LEADS_TO", "DISPROVES", "CONFIRMS", "TRIGGERS"
}

type SemanticDecisionGraph struct {
	SessionID string         `json:"session_id"`
	Nodes     []SemanticNode `json:"nodes"`
	Edges     []SemanticEdge `json:"edges"`
}

// ===========================
// Pattern Summary (What LLM actually sees)
// Instead of 300 raw events, LLM receives this compact digest.
// ===========================

type PatternSummary struct {
	SessionID        string                 `json:"session_id"`
	Patterns         []CognitivePattern     `json:"patterns"`
	DominantStrategy PatternType            `json:"dominant_strategy"`
	SemanticGraph    *SemanticDecisionGraph `json:"semantic_graph,omitempty"`
	// Aggregated metrics
	TotalPatterns     int     `json:"total_patterns"`
	AIReliance        float64 `json:"ai_reliance"`        // 0.0–1.0
	PersistenceScore  float64 `json:"persistence_score"`  // 0.0–1.0
	StrategyDiversity int     `json:"strategy_diversity"` // Number of distinct pattern types
}
