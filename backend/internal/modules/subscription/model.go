package subscription

type Subscription struct {
	ID                    int64   `json:"id" db:"id"`
	UserID                int64   `json:"user_id" db:"user_id"`
	Tier                  string  `json:"tier" db:"tier"`
	Status                string  `json:"status" db:"status"`
	StartDate             string  `json:"start_date" db:"start_date"`
	EndDate               *string `json:"end_date,omitempty" db:"end_date"`
	PaymentReference      *string `json:"payment_reference,omitempty" db:"payment_reference"`
	BillingProvider       *string `json:"billing_provider,omitempty" db:"billing_provider"`
	ProviderSubscriptionID *string `json:"provider_subscription_id,omitempty" db:"provider_subscription_id"`
	AutoRenew             bool    `json:"auto_renew" db:"auto_renew"`
}

type CreateRequest struct {
	Tier             string `json:"tier" binding:"required,oneof=premium pro"`
	PaymentReference string `json:"payment_reference" binding:"required"`
	BillingProvider  string `json:"billing_provider" binding:"required"`
}
