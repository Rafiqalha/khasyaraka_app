// Deprecated. Replaced by Academy SDK. Will be removed after migration.
package survival

type Mastery struct {
	ID              int64   `json:"id" db:"id"`
	UserID          int64   `json:"user_id" db:"user_id"`
	ToolType        string  `json:"tool_type" db:"tool_type"`
	CurrentXP       int     `json:"current_xp" db:"current_xp"`
	CurrentLevel    int     `json:"current_level" db:"current_level"`
	TotalActions    int     `json:"total_actions" db:"total_actions"`
	HighestStreak   int     `json:"highest_streak" db:"highest_streak"`
	MaxAltitude     float64 `json:"max_altitude" db:"max_altitude"`
	TotalDistanceKm float64 `json:"total_distance_km" db:"total_distance_tracked"`
}

type ActionRequest struct {
	ToolType string  `json:"tool_type" binding:"required"`
	Distance float64 `json:"distance_km"`
	Altitude float64 `json:"altitude_m"`
	IsStreak bool    `json:"is_streak"`
}

type LeaderboardEntry struct {
	UserID   int64  `json:"user_id" db:"user_id"`
	FullName string `json:"full_name" db:"full_name"`
	TotalXP  int    `json:"total_xp" db:"total_xp"`
	ToolType string `json:"tool_type" db:"tool_type"`
	Level    int    `json:"level" db:"level"`
}
