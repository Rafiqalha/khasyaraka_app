package governance

import (
	"context"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	GetPolicy(ctx context.Context, name string) (*Policy, error)
	GetRules(ctx context.Context, policyID string) ([]Rule, error)
	GetStrategy(ctx context.Context, name string) (*Strategy, error)
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) GetPolicy(ctx context.Context, name string) (*Policy, error) {
	var p Policy
	err := r.db.GetContext(ctx, &p, "SELECT * FROM governance_policies WHERE name = $1", name)
	if err != nil {
		return nil, err
	}
	return &p, nil
}

func (r *repository) GetRules(ctx context.Context, policyID string) ([]Rule, error) {
	var rules []Rule
	err := r.db.SelectContext(ctx, &rules, "SELECT * FROM governance_rules WHERE policy_id = $1", policyID)
	return rules, err
}

func (r *repository) GetStrategy(ctx context.Context, name string) (*Strategy, error) {
	var s Strategy
	err := r.db.GetContext(ctx, &s, "SELECT * FROM governance_strategies WHERE name = $1", name)
	if err != nil {
		return nil, err
	}
	return &s, nil
}
