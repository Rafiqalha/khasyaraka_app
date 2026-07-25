package catalog

import (
	"context"
	"database/sql"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	FindGoalBySlug(ctx context.Context, slug string) (*Goal, error)
	FindGoalByID(ctx context.Context, id string) (*Goal, error)
	GetAllAcademies(ctx context.Context) ([]Academy, error)
	GetSpecializationsByAcademyID(ctx context.Context, academyID string) ([]Specialization, error)
	InitializeJourneyTransaction(ctx context.Context, userID, enrollmentID, runtimeID, snapshotID, academyID, specializationID string) error
	// TODO: Add FindPathByGoalID, FindPackByPathID etc.
}

type catalogRepository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) Repository {
	return &catalogRepository{db: db}
}

func (r *catalogRepository) FindGoalBySlug(ctx context.Context, slug string) (*Goal, error) {
	var goal Goal
	query := `SELECT * FROM learning_goals WHERE slug = $1 LIMIT 1`
	err := r.db.GetContext(ctx, &goal, query, slug)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &goal, nil
}

func (r *catalogRepository) FindGoalByID(ctx context.Context, id string) (*Goal, error) {
	var goal Goal
	query := `SELECT * FROM learning_goals WHERE id = $1 LIMIT 1`
	err := r.db.GetContext(ctx, &goal, query, id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &goal, nil
}

func (r *catalogRepository) GetAllAcademies(ctx context.Context) ([]Academy, error) {
	var academies []Academy
	query := `SELECT * FROM academies ORDER BY created_at ASC`
	err := r.db.SelectContext(ctx, &academies, query)
	if err != nil {
		return nil, err
	}
	return academies, nil
}

func (r *catalogRepository) GetSpecializationsByAcademyID(ctx context.Context, academyID string) ([]Specialization, error) {
	var specs []Specialization
	// Domains belong to Academy, Specializations belong to Domains
	query := `
		SELECT s.* 
		FROM specializations s
		JOIN domains d ON s.domain_id = d.id
		WHERE d.academy_id = $1
		ORDER BY s.created_at ASC
	`
	err := r.db.SelectContext(ctx, &specs, query, academyID)
	if err != nil {
		return nil, err
	}
	return specs, nil
}

func (r *catalogRepository) InitializeJourneyTransaction(ctx context.Context, userID, enrollmentID, runtimeID, snapshotID, academyID, specializationID string) error {
	tx, err := r.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// 1. Create Enrollment
	_, err = tx.ExecContext(ctx, `
		INSERT INTO learning_enrollments (id, user_id, academy_id, specialization_id, blueprint_version, status)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (user_id, specialization_id) DO NOTHING
	`, enrollmentID, userID, academyID, specializationID, "1.0.0", "ACTIVE")
	if err != nil {
		return err
	}

	// 2. Create initial Runtime Session
	_, err = tx.ExecContext(ctx, `
		INSERT INTO runtime_sessions (id, user_id, enrollment_id)
		VALUES ($1, $2, $3)
	`, runtimeID, userID, enrollmentID)
	if err != nil {
		return err
	}

	// 3. Create initial Planner Snapshot
	strategyPayload := `{"mission": "Initial Setup", "focus": "Fundamentals"}`
	_, err = tx.ExecContext(ctx, `
		INSERT INTO planner_snapshots (id, enrollment_id, runtime_session_id, strategy_payload)
		VALUES ($1, $2, $3, $4)
	`, snapshotID, enrollmentID, runtimeID, strategyPayload)
	if err != nil {
		return err
	}

	return tx.Commit()
}
