package cognitive_pattern

import (
	"time"

	"github.com/oklog/ulid/v2"
)

// ===========================
// Semantic Graph Builder
// Transforms raw Activity Graph (Read Error, Run, Ask Mentor)
// into Semantic Decision Graph (Hypothesis, Verification, Failure, Recovery).
// Deterministic. No LLM.
// ===========================

// activityToSemantic maps raw event types to semantic node types.
var activityToSemantic = map[string]CognitiveIntent{
	// Exploration
	"OPEN_FILE":           IntentExplore,
	"READ_DOCS":           IntentExplore,
	"EnvironmentChanged":  IntentExplore,

	// Hypothesis (editing = proposing a fix)
	"SAVE_FILE":           IntentHypothesis,
	"ArtifactCreated":     IntentHypothesis,
	"ArtifactModified":    IntentHypothesis,

	// Verification (running = testing hypothesis)
	"RUN_CODE":            IntentValidate,
	"ToolExecuted":        IntentValidate,
	"RUN_TESTS":           IntentValidate,

	// Failure
	"COMPILE_ERROR":       IntentFailure,
	"RUNTIME_ERROR":       IntentFailure,
	"TEST_FAILED":         IntentFailure,

	// Delegation (asking for help)
	"ASK_MENTOR":          IntentDelegation,
	"AgentRequested":      IntentDelegation,
	"AgentResponded":      IntentDelegation,

	// Confirmation
	"ObjectiveCompleted":  IntentValidate, // Or create IntentConfirmation
	"MissionCompleted":    IntentValidate,

	// Abandonment
	"MissionAbandoned":    IntentExplore, // Mapped fallback
}

// edgeRelations determines the semantic relationship based on consecutive node types.
var edgeRelations = map[[2]CognitiveIntent]string{
	{IntentHypothesis, IntentValidate}:  "LEADS_TO",
	{IntentValidate, IntentFailure}:     "DISPROVES",
	{IntentValidate, IntentOptimize}:    "CONFIRMS",
	{IntentFailure, IntentHypothesis}:   "TRIGGERS",
	{IntentFailure, IntentDelegation}:   "TRIGGERS",
	{IntentDelegation, IntentHypothesis}: "LEADS_TO",
	{IntentExplore, IntentHypothesis}:   "LEADS_TO",
	{IntentFailure, IntentExplore}:      "TRIGGERS",
}

type SemanticGraphBuilder struct{}

func NewSemanticGraphBuilder() *SemanticGraphBuilder {
	return &SemanticGraphBuilder{}
}

// Build transforms a sequence of raw activity events into a Semantic Decision Graph.
func (b *SemanticGraphBuilder) Build(sessionID string, events []ActivityEvent) *SemanticDecisionGraph {
	graph := &SemanticDecisionGraph{
		SessionID: sessionID,
	}

	if len(events) == 0 {
		return graph
	}

	// 1. Map each raw event to a semantic node (collapsing consecutive same-type nodes)
	var lastNodeType CognitiveIntent
	for _, e := range events {
		semType, ok := activityToSemantic[e.Type]
		if !ok {
			continue // Skip unknown event types
		}

		// Collapse consecutive same-type nodes
		if semType == lastNodeType && len(graph.Nodes) > 0 {
			// Merge: append source ID to existing node
			last := &graph.Nodes[len(graph.Nodes)-1]
			last.SourceActivityIDs = append(last.SourceActivityIDs, e.ID)
			continue
		}

		node := SemanticNode{
			ID:                ulid.Make().String(),
			SessionID:         sessionID,
			NodeType:          semType,
			SourceActivityIDs: []string{e.ID},
			Summary:           string(semType),
			OccurredAt:        e.Timestamp,
		}
		graph.Nodes = append(graph.Nodes, node)
		lastNodeType = semType
	}

	// 2. Connect nodes with semantic edges
	for i := 1; i < len(graph.Nodes); i++ {
		prev := graph.Nodes[i-1]
		curr := graph.Nodes[i]

		relation := "FOLLOWS" // default
		if r, ok := edgeRelations[[2]CognitiveIntent{prev.NodeType, curr.NodeType}]; ok {
			relation = r
		}

		graph.Edges = append(graph.Edges, SemanticEdge{
			FromNodeID: prev.ID,
			ToNodeID:   curr.ID,
			Relation:   relation,
		})
	}

	return graph
}

// ===========================
// Cognitive Pattern Service
// Coordinates Pattern Detection + Semantic Graph Building
// ===========================

type Service struct {
	detector     *PatternDetector
	graphBuilder *SemanticGraphBuilder
}

func NewService() *Service {
	return &Service{
		detector:     NewPatternDetector(),
		graphBuilder: NewSemanticGraphBuilder(),
	}
}

// Analyze runs the full cognitive analysis pipeline on a session's events.
// Returns a PatternSummary with both detected patterns and the semantic graph.
func (s *Service) Analyze(sessionID string, events []ActivityEvent) *PatternSummary {
	// 1. Detect patterns
	summary := s.detector.Detect(sessionID, events)

	// 2. Build semantic graph
	summary.SemanticGraph = s.graphBuilder.Build(sessionID, events)

	return summary
}

// placeholder to prevent lint
var _ = time.Now
