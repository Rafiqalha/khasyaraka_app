package chat

import (
	"regexp"
	"strings"
)

func ModerateContent(content string) (string, bool) {
	// Blocked words list (Indonesian context):
	blockedWords := []string{
		"anjing", "babi", "bangsat", "kontol", "memek", 
		"ngentot", "tolol", "goblok", "bajingan", "asu",
	}
	
	lower := strings.ToLower(content)
	for _, word := range blockedWords {
		if strings.Contains(lower, word) {
			return "", false
		}
	}
	
	// Sanitize: trim, normalize spaces
	clean := strings.TrimSpace(content)
	clean = regexp.MustCompile(`\s+`).ReplaceAllString(clean, " ")
	
	return clean, true
}
