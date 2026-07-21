// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package sku

type SKUPoint struct {
	ID          string      `json:"id" db:"id"`
	Level       string      `json:"level" db:"level"`
	Number      int         `json:"number" db:"number"`
	Title       string      `json:"title" db:"title"`
	Description string      `json:"description" db:"description"`
	Category    string      `json:"category" db:"category"`
	QuizContent interface{} `json:"quiz_content" db:"quiz_content"`
	IsCompleted bool        `json:"is_completed,omitempty"`
	Score       int         `json:"score,omitempty"`
}

type SKUProgress struct {
	UserID      int64  `json:"user_id" db:"user_id"`
	SKUPointID  string `json:"sku_point_id" db:"sku_point_id"`
	IsCompleted bool   `json:"is_completed" db:"is_completed"`
	Score       int    `json:"score" db:"score"`
}

type SubmitQuizRequest struct {
	Answers []string `json:"answers" binding:"required"`
}
