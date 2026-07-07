package token

import (
	"context"
	"database/sql"
	"errors"

	"github.com/jmoiron/sqlx"
)

type Repository interface {
	GetByUserID(ctx context.Context, userID int64) (*UserToken, error)
	Create(ctx context.Context, userID int64, tier string, dailyLimit int) (*UserToken, error)
	DeductOne(ctx context.Context, userID int64) error
	RefundOne(ctx context.Context, userID int64) error
	ResetIfNewDay(ctx context.Context, userID int64) error
	UpdateTier(ctx context.Context, userID int64, tier string, dailyLimit int) error
}

type PostgresTokenRepository struct {
	db *sqlx.DB
}

func NewPostgresTokenRepository(db *sqlx.DB) *PostgresTokenRepository {
	return &PostgresTokenRepository{db: db}
}

func (r *PostgresTokenRepository) GetByUserID(ctx context.Context, userID int64) (*UserToken, error) {
	var token UserToken
	err := r.db.GetContext(ctx, &token, "SELECT * FROM user_tokens WHERE user_id = $1", userID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &token, nil
}

func (r *PostgresTokenRepository) Create(ctx context.Context, userID int64, tier string, dailyLimit int) (*UserToken, error) {
	query := `
		INSERT INTO user_tokens (user_id, tier, daily_limit, used_today)
		VALUES ($1, $2, $3, 0)
		ON CONFLICT (user_id) DO NOTHING
		RETURNING *
	`
	var token UserToken
	err := r.db.GetContext(ctx, &token, query, userID, tier, dailyLimit)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			// Already exists, just return it
			return r.GetByUserID(ctx, userID)
		}
		return nil, err
	}
	return &token, nil
}

func (r *PostgresTokenRepository) DeductOne(ctx context.Context, userID int64) error {
	query := `
		UPDATE user_tokens 
		SET used_today = used_today + 1
		WHERE user_id = $1 AND used_today < daily_limit
	`
	res, err := r.db.ExecContext(ctx, query, userID)
	if err != nil {
		return err
	}
	rows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return errors.New("token limit reached")
	}
	return nil
}

func (r *PostgresTokenRepository) RefundOne(ctx context.Context, userID int64) error {
	query := `
		UPDATE user_tokens 
		SET used_today = GREATEST(0, used_today - 1)
		WHERE user_id = $1
	`
	_, err := r.db.ExecContext(ctx, query, userID)
	return err
}

func (r *PostgresTokenRepository) ResetIfNewDay(ctx context.Context, userID int64) error {
	// Check if last_reset < today in WIB (UTC+7)
	// PostgreSQL DATE() uses database timezone, we ensure WIB logic in Go or SQL.
	// For simplicity, we just use raw SQL to reset if last_reset is before today in +07.
	query := `
		UPDATE user_tokens 
		SET used_today = 0, last_reset = NOW()
		WHERE user_id = $1 
		AND (last_reset AT TIME ZONE 'Asia/Jakarta')::date < (NOW() AT TIME ZONE 'Asia/Jakarta')::date
	`
	_, err := r.db.ExecContext(ctx, query, userID)
	return err
}

func (r *PostgresTokenRepository) UpdateTier(ctx context.Context, userID int64, tier string, dailyLimit int) error {
	query := `
		UPDATE user_tokens 
		SET tier = $2, daily_limit = $3
		WHERE user_id = $1
	`
	_, err := r.db.ExecContext(ctx, query, userID, tier, dailyLimit)
	return err
}
