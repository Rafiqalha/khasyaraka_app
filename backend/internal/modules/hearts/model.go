package hearts

// HeartsResponse is the standard response for hearts queries.
type HeartsResponse struct {
	UserID    int64 `json:"user_id"`
	Hearts    int   `json:"hearts"`
	MaxHearts int   `json:"max_hearts"`
}

// DecrementRequest is the request body for hearts decrement.
type DecrementRequest struct {
	Amount int `json:"amount" binding:"required,min=1,max=5"`
}

// IncrementRequest is the request body for hearts increment.
type IncrementRequest struct {
	Amount int `json:"amount" binding:"required,min=1,max=5"`
}
