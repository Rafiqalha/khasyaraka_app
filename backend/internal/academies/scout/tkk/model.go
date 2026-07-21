// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package tkk

type TKKBadge struct {
	ID         int64  `json:"id" db:"id"`
	UserID     int64  `json:"user_id" db:"user_id"`
	TkkSlug    string `json:"tkk_slug" db:"tkk_slug"`
	Level      string `json:"level" db:"level"`
	AttainedAt string `json:"attained_at" db:"attained_at"`
}

type AttainRequest struct {
	TkkSlug string `json:"tkk_slug" binding:"required"`
	Level   string `json:"level" binding:"required,oneof=purwa madya utama"`
}
