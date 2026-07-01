package subscription

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) GetActiveByUser(userID int64) (*Subscription, error) {
	var s Subscription
	err := r.db.Get(&s, `SELECT id, user_id, tier, status, start_date, end_date,
		payment_reference, billing_provider, provider_subscription_id, auto_renew
		FROM subscriptions WHERE user_id = $1 AND status = 'active' AND (end_date IS NULL OR end_date > NOW())
		ORDER BY start_date DESC LIMIT 1`, userID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get subscription: %w", err)
	}
	return &s, nil
}

func (r *Repository) Create(userID int64, tier, paymentRef, provider string) (*Subscription, error) {
	endDate := time.Now().AddDate(0, 1, 0) // 1 month
	var s Subscription
	err := r.db.QueryRowx(`
		INSERT INTO subscriptions (user_id, tier, status, end_date, payment_reference, billing_provider, auto_renew)
		VALUES ($1, $2, 'active', $3, $4, $5, TRUE)
		RETURNING id, user_id, tier, status, start_date, end_date, payment_reference, billing_provider, provider_subscription_id, auto_renew
	`, userID, tier, endDate, paymentRef, provider).StructScan(&s)
	if err != nil {
		return nil, fmt.Errorf("create subscription: %w", err)
	}
	return &s, nil
}

func (r *Repository) Cancel(userID int64) error {
	_, err := r.db.Exec("UPDATE subscriptions SET status = 'cancelled', auto_renew = FALSE, updated_at = NOW() WHERE user_id = $1 AND status = 'active'", userID)
	return err
}
