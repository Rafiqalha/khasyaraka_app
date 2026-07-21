package aggregation

type ActivityAggregate struct {
	SchemaVersion    string `json:"schema_version"`
	SessionID        string `json:"session_id"`
	UserID           string `json:"user_id"`
	TenantID         string `json:"tenant_id"`
	Duration         int    `json:"duration"`
	TypingCount      int    `json:"typing_count"`
	TypingCharacters int    `json:"typing_characters"`
	AIRequests       int    `json:"ai_requests"`
	CodeRuns         int    `json:"code_runs"`
	CompileSuccess   int    `json:"compile_success"`
	CompileFailed    int    `json:"compile_failed"`
	FocusSeconds     int    `json:"focus_seconds"`
	IdleSeconds      int    `json:"idle_seconds"`
}
