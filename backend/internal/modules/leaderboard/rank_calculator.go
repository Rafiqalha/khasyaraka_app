package leaderboard

type RankInfo struct {
	RankName   string `json:"rank_name"`
	SubTier    string `json:"sub_tier"`
	Stars      int    `json:"stars"`
	MaxStars   int    `json:"max_stars"`
	TotalStars int    `json:"total_stars"`
}

func CalculateRank(totalStars int) RankInfo {
	if totalStars < 0 {
		totalStars = 0
	}

	// Kasta Siaga (0 - 8 stars)
	if totalStars < 9 {
		// 3 Bintang per Sub-tier (III, II, I)
		tiers := []string{"III", "II", "I"}
		subTierIndex := totalStars / 3
		starsInTier := totalStars % 3
		return RankInfo{
			RankName:   "Kasta Siaga",
			SubTier:    tiers[subTierIndex],
			Stars:      starsInTier,
			MaxStars:   3,
			TotalStars: totalStars,
		}
	}

	// Kasta Penggalang (9 - 24 stars)
	if totalStars < 25 {
		// 4 Bintang per Sub-tier (IV, III, II, I)
		starsInRank := totalStars - 9
		tiers := []string{"IV", "III", "II", "I"}
		subTierIndex := starsInRank / 4
		starsInTier := starsInRank % 4
		return RankInfo{
			RankName:   "Kasta Penggalang",
			SubTier:    tiers[subTierIndex],
			Stars:      starsInTier,
			MaxStars:   4,
			TotalStars: totalStars,
		}
	}

	// Kasta Penegak (25 - 49 stars)
	if totalStars < 50 {
		// 5 Bintang per Sub-tier (V, IV, III, II, I)
		starsInRank := totalStars - 25
		tiers := []string{"V", "IV", "III", "II", "I"}
		subTierIndex := starsInRank / 5
		starsInTier := starsInRank % 5
		return RankInfo{
			RankName:   "Kasta Penegak",
			SubTier:    tiers[subTierIndex],
			Stars:      starsInTier,
			MaxStars:   5,
			TotalStars: totalStars,
		}
	}

	// Kasta Pandega (50 - 74 stars)
	if totalStars < 75 {
		// 5 Bintang per Sub-tier (V, IV, III, II, I)
		starsInRank := totalStars - 50
		tiers := []string{"V", "IV", "III", "II", "I"}
		subTierIndex := starsInRank / 5
		starsInTier := starsInRank % 5
		return RankInfo{
			RankName:   "Kasta Pandega",
			SubTier:    tiers[subTierIndex],
			Stars:      starsInTier,
			MaxStars:   5,
			TotalStars: totalStars,
		}
	}

	// Garuda (Mythic) (75+ stars)
	starsInRank := totalStars - 75
	return RankInfo{
		RankName:   "Garuda",
		SubTier:    "Mythic",
		Stars:      starsInRank,
		MaxStars:   -1, // Indicates unlimited
		TotalStars: totalStars,
	}
}
