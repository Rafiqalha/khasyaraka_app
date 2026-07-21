package learning_graph

import "time"

// Node represents an executed or planned activity in the user's Learning Graph.
type Node struct {
	ID              string    `json:"id" db:"id"`
	UserID          string    `json:"user_id" db:"user_id"`
	LearningAssetID string    `json:"learning_asset_id" db:"learning_asset_id"` // Ties to a Concept
	Status          string    `json:"status" db:"status"`                       // "planned", "in_progress", "completed", "failed", "abandoned"
	EvidenceID      *string   `json:"evidence_id,omitempty" db:"evidence_id"`   // Populated once completed
	CreatedAt       time.Time `json:"created_at" db:"created_at"`
}

// Edge represents the directed traversal from one Node to another.
type Edge struct {
	SourceNodeID string `json:"source_node_id" db:"source_node_id"`
	TargetNodeID string `json:"target_node_id" db:"target_node_id"`
	Reason       string `json:"reason" db:"reason"` // e.g., "next_in_route", "remediation", "backtrack"
}

// Graph represents the persistent history (GPS History) of the user's learning path.
type Graph struct {
	UserID string `json:"user_id"`
	Nodes  []Node `json:"nodes"`
	Edges  []Edge `json:"edges"`
}

// RouteRecommendation is the ephemeral output of the RouteEngine.
type RouteRecommendation struct {
	GoalConceptID     string   `json:"goal_concept_id"`
	RecommendedAssets []string `json:"recommended_assets"` // List of LearningAsset IDs
	EstimatedSuccess  float64  `json:"estimated_success"`  // E.g., 0.82 (82% probability)
}
