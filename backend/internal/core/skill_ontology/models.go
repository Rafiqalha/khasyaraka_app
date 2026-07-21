package skill_ontology

import "time"

type Node struct {
	ID          string    `db:"id" json:"id"`
	Name        string    `db:"name" json:"name"`
	Description string    `db:"description" json:"description"`
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
}

type Relation struct {
	ID           string    `db:"id" json:"id"`
	ParentNodeID string    `db:"parent_node_id" json:"parent_node_id"`
	ChildNodeID  string    `db:"child_node_id" json:"child_node_id"`
	RelationType string    `db:"relation_type" json:"relation_type"`
	CreatedAt    time.Time `db:"created_at" json:"created_at"`
}
