package competency_graph

import "time"

type CompetencyContribution struct {
	ID                 string      `db:"id" json:"id"`
	UserID             string      `db:"user_id" json:"user_id"`
	EvidenceID         string      `db:"evidence_id" json:"evidence_id"`
	SkillNodeID        string      `db:"skill_node_id" json:"skill_node_id"`
	KnowledgeLineageID string      `db:"knowledge_lineage_id" json:"knowledge_lineage_id"`
	Kind               DeltaSource `db:"kind" json:"kind"`
	Magnitude          float64     `db:"magnitude" json:"magnitude"`
	Confidence         float64     `db:"confidence" json:"confidence"`
	Weight             float64     `db:"weight" json:"weight"`
	CreatedAt          time.Time   `db:"created_at" json:"created_at"`
}

type ProjectionStatus string

const (
	ProjectionFresh       ProjectionStatus = "FRESH"
	ProjectionExpired     ProjectionStatus = "EXPIRED"
	ProjectionInvalidated ProjectionStatus = "INVALIDATED"
	ProjectionRebuilding  ProjectionStatus = "REBUILDING"
)

type ProjectionExplanation struct {
	TopPositiveContributions []string `json:"top_positive_contributions"`
	TopNegativeContributions []string `json:"top_negative_contributions"`
	DecayApplied             float64  `json:"decay_applied"`
	PropagationApplied       bool     `json:"propagation_applied"`
	PolicyApplied            string   `json:"policy_applied"`
}

type ProjectionMetrics struct {
	Duration         int64 `json:"duration"`
	NodesVisited     int   `json:"nodes_visited"`
	EdgesTraversed   int   `json:"edges_traversed"`
	DecayApplied     bool  `json:"decay_applied"`
	PropagationCount int   `json:"propagation_count"`
	CacheHit         bool  `json:"cache_hit"`
}
