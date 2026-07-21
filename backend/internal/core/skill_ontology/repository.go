package skill_ontology

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	GetNodeByName(ctx context.Context, name string) (*Node, error)
	GetChildren(ctx context.Context, parentID string) ([]Node, error)
	GetParents(ctx context.Context, childID string) ([]Node, error)
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) GetNodeByName(ctx context.Context, name string) (*Node, error) {
	var n Node
	err := r.db.GetContext(ctx, &n, "SELECT * FROM skill_ontology_nodes WHERE name = $1", name)
	if err != nil {
		return nil, err
	}
	return &n, nil
}

func (r *repository) GetChildren(ctx context.Context, parentID string) ([]Node, error) {
	var nodes []Node
	query := `
		SELECT n.* FROM skill_ontology_nodes n
		JOIN skill_ontology_relations r ON n.id = r.child_node_id
		WHERE r.parent_node_id = $1
	`
	err := r.db.SelectContext(ctx, &nodes, query, parentID)
	return nodes, err
}

func (r *repository) GetParents(ctx context.Context, childID string) ([]Node, error) {
	var nodes []Node
	query := `
		SELECT n.* FROM skill_ontology_nodes n
		JOIN skill_ontology_relations r ON n.id = r.parent_node_id
		WHERE r.child_node_id = $1
	`
	err := r.db.SelectContext(ctx, &nodes, query, childID)
	return nodes, err
}
