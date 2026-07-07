package ctf

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"regexp"
	"strings"
)

func GenerateFlag() string {
	const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	length := 6
	b := make([]byte, length)
	for i := range b {
		n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
		b[i] = charset[n.Int64()]
	}
	return fmt.Sprintf("FLAG{PRADIGI_%s}", string(b))
}

func ValidateFlag(flag string) bool {
	matched, _ := regexp.MatchString(`^FLAG\{PRADIGI_[A-Z0-9]{6}\}$`, flag)
	return matched
}

func GetRandomCulturalImage() CulturalImage {
	n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(CulturalImagePool))))
	return CulturalImagePool[n.Int64()]
}

func GetPatchChallenge(difficulty string) PatchChallengeTemplate {
	var filtered []PatchChallengeTemplate
	for _, c := range PatchChallengesPool {
		if c.Difficulty == difficulty {
			filtered = append(filtered, c)
		}
	}
	if len(filtered) == 0 {
		return PatchChallengesPool[0] // fallback
	}
	n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(filtered))))
	return filtered[n.Int64()]
}

func NormalizeAnswer(answer string) string {
	ans := strings.TrimSpace(answer)
	ans = strings.ToUpper(ans)
	// Remove special characters
	re := regexp.MustCompile(`[^A-Z0-9]`)
	return re.ReplaceAllString(ans, "")
}
