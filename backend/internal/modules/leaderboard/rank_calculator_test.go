package leaderboard

import (
	"testing"
)

func TestCalculateRank(t *testing.T) {
	tests := []struct {
		totalStars int
		expected   RankInfo
	}{
		{0, RankInfo{"Kasta Siaga", "III", 0, 3, 0}},
		{2, RankInfo{"Kasta Siaga", "III", 2, 3, 2}},
		{3, RankInfo{"Kasta Siaga", "II", 0, 3, 3}},
		{8, RankInfo{"Kasta Siaga", "I", 2, 3, 8}},
		{9, RankInfo{"Kasta Penggalang", "IV", 0, 4, 9}},
		{24, RankInfo{"Kasta Penggalang", "I", 3, 4, 24}},
		{25, RankInfo{"Kasta Penegak", "V", 0, 5, 25}},
		{49, RankInfo{"Kasta Penegak", "I", 4, 5, 49}},
		{50, RankInfo{"Kasta Pandega", "V", 0, 5, 50}},
		{74, RankInfo{"Kasta Pandega", "I", 4, 5, 74}},
		{75, RankInfo{"Garuda", "Mythic", 0, -1, 75}},
		{100, RankInfo{"Garuda", "Mythic", 25, -1, 100}},
	}

	for _, tt := range tests {
		actual := CalculateRank(tt.totalStars)
		if actual != tt.expected {
			t.Errorf("CalculateRank(%d) = %+v, expected %+v", tt.totalStars, actual, tt.expected)
		}
	}
}
