package mission_specification

import (
	"context"
	"github.com/jmoiron/sqlx"
)

type Repository interface {
	CreateActivity(ctx context.Context, a LearningActivity) error
}

type repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &repository{db: db}
}

func (r *repository) CreateActivity(ctx context.Context, a LearningActivity) error {
	query := `
		INSERT INTO learning_activities (id, user_id, tenant_id, source_engine, source_id, artifact_id, activity_type, payload, schema_version)
		VALUES (:id, :user_id, :tenant_id, :source_engine, :source_id, :artifact_id, :activity_type, :payload, :schema_version)
	`
	_, err := r.db.NamedExecContext(ctx, query, a)
	return err
}
