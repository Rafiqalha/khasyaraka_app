package governance

import (
	"encoding/json"
	"time"
)

type Policy struct {
	ID          string          `db:"id" json:"id"`
	Name        string          `db:"name" json:"name"`
	Description string          `db:"description" json:"description"`
	Config      json.RawMessage `db:"config" json:"config"`
	CreatedAt   time.Time       `db:"created_at" json:"created_at"`
}

type Rule struct {
	ID        string          `db:"id" json:"id"`
	PolicyID  string          `db:"policy_id" json:"policy_id"`
	Name      string          `db:"name" json:"name"`
	Condition json.RawMessage `db:"condition" json:"condition"`
	CreatedAt time.Time       `db:"created_at" json:"created_at"`
}

type Strategy struct {
	ID         string          `db:"id" json:"id"`
	Name       string          `db:"name" json:"name"` // e.g., 'BayesianUpdate', 'ExponentialDecay'
	Parameters json.RawMessage `db:"parameters" json:"parameters"`
	CreatedAt  time.Time       `db:"created_at" json:"created_at"`
}
