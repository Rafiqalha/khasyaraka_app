package leaderboard

type Entry struct {
	Rank     int    `json:"rank"`
	UserID   int64  `json:"user_id"`
	FullName string `json:"full_name"`
	TotalXP  int    `json:"total_xp"`
	HackLevel string `json:"hack_level"`
}

type UserRank struct {
	Rank     int    `json:"rank"`
	TotalXP  int    `json:"total_xp"`
	TopCount int    `json:"top_count"`
}
