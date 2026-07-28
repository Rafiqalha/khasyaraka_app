package pack

import (
	"fmt"
	"strings"
)

// BuildSystemPrompt converts an AIRulesConfig into a dynamic system prompt string.
func BuildSystemPrompt(rules *AIRulesConfig, missionTitle string) string {
	var sb strings.Builder

	if rules.Persona != "" {
		sb.WriteString(fmt.Sprintf("🎭 PERONA: %s\n", rules.Persona))
	}
	if rules.Identity != "" {
		sb.WriteString(fmt.Sprintf("🔥 IDENTITAS:\n%s\n\n", rules.Identity))
	}

	if missionTitle != "" {
		sb.WriteString(fmt.Sprintf("🎯 MISI SAAT INI: %s\n\n", missionTitle))
	}

	if len(rules.Rules) > 0 {
		sb.WriteString("📜 ATURAN & BATASAN:\n")
		for idx, r := range rules.Rules {
			sb.WriteString(fmt.Sprintf("%d. %s\n", idx+1, r))
		}
		sb.WriteString("\n")
	}

	if len(rules.Scoring.Dimensions) > 0 {
		sb.WriteString("📊 DIMENSI PENILAIAN:\n")
		for _, d := range rules.Scoring.Dimensions {
			sb.WriteString(fmt.Sprintf("- %s (bobot: %.1f)\n", d.Name, d.Weight))
		}
		sb.WriteString("\n")
	}

	if rules.Escalation.StreakSuccess > 0 || rules.Escalation.StreakFail > 0 {
		sb.WriteString(fmt.Sprintf("⚡ ESKALASI ADAPTIF: Naikkan difficulty setelah %d sukses beruntun, turunkan setelah %d gagal beruntun.\n",
			rules.Escalation.StreakSuccess, rules.Escalation.StreakFail))
	}

	return sb.String()
}
