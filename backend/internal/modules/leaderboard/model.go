package leaderboard

type Entry struct {
	Rank        int      `json:"rank"`
	UserID      int64    `json:"user_id"`
	FullName    string   `json:"full_name"`
	TotalXP     int      `json:"total_xp"`
	HackLevel   string   `json:"hack_level"`
	CountryID   string   `json:"country_id"`
	ProvinsiID  string   `json:"provinsi_id"`
	KabupatenID string   `json:"kabupaten_id"`
	KecamatanID string   `json:"kecamatan_id"`
	RankInfo    RankInfo `json:"rank_info"`
}

type UserRank struct {
	Rank     int      `json:"rank"`
	TotalXP  int      `json:"total_xp"`
	TopCount int      `json:"top_count"`
	RankInfo RankInfo `json:"rank_info"`
}
