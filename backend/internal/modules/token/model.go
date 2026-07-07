package token

import "time"

const (
	TierFree = "free"
	TierPro  = "pro"
	TierMax  = "max"
)

var TierLimits = map[string]int{
	TierFree: 3,
	TierPro:  10,
	TierMax:  30,
}

type UserToken struct {
	ID         int64     `json:"id" db:"id"`
	UserID     int64     `json:"user_id" db:"user_id"`
	Tier       string    `json:"tier" db:"tier"`
	DailyLimit int       `json:"daily_limit" db:"daily_limit"`
	UsedToday  int       `json:"used_today" db:"used_today"`
	LastReset  time.Time `json:"last_reset" db:"last_reset"`
	CreatedAt  time.Time `json:"created_at" db:"created_at"`
	UpdatedAt  time.Time `json:"updated_at" db:"updated_at"`
}

type TokenStatus struct {
	Tier       string `json:"tier"`
	DailyLimit int    `json:"daily_limit"`
	UsedToday  int    `json:"used_today"`
	Remaining  int    `json:"remaining"`
	ResetsAt   string `json:"resets_at"`
}
