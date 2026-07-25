package telemetry

import (
	"encoding/json"
	"regexp"
)

type Sanitizer struct {
	emailRegex *regexp.Regexp
	tokenRegex *regexp.Regexp
	ipRegex    *regexp.Regexp
}

func NewSanitizer() *Sanitizer {
	return &Sanitizer{
		emailRegex: regexp.MustCompile(`[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`),
		tokenRegex: regexp.MustCompile(`(eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)|(sk-[a-zA-Z0-9]{48})`),
		ipRegex:    regexp.MustCompile(`\b(?:\d{1,3}\.){3}\d{1,3}\b`),
	}
}

// SanitizePayload takes a JSON string and redacts PII
func (s *Sanitizer) SanitizePayload(payload string) string {
	if payload == "" {
		return ""
	}

	redacted := s.emailRegex.ReplaceAllString(payload, "[REDACTED_EMAIL]")
	redacted = s.tokenRegex.ReplaceAllString(redacted, "[REDACTED_TOKEN]")
	redacted = s.ipRegex.ReplaceAllString(redacted, "[REDACTED_IP]")

	return redacted
}

// SanitizeMap takes a generic map and sanitizes string values
func (s *Sanitizer) SanitizeMap(data map[string]interface{}) map[string]interface{} {
	b, err := json.Marshal(data)
	if err != nil {
		return data
	}

	sanitizedStr := s.SanitizePayload(string(b))
	var result map[string]interface{}
	if err := json.Unmarshal([]byte(sanitizedStr), &result); err != nil {
		return data
	}
	return result
}
