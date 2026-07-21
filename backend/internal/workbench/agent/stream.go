package agent

import "time"

// ===========================
// Agent Streaming Abstraction
// Masks the underlying LLM provider (OpenAI, DeepSeek) so the frontend
// and SSE layers only deal with standard chunks.
// ===========================

type AgentResponseChunk struct {
	RoleID    string    `json:"role_id"` // e.g. "mentor"
	MessageID string    `json:"message_id"`
	Token     string    `json:"token"`
	IsDone    bool      `json:"is_done"`
	Timestamp time.Time `json:"timestamp"`
}

// StreamPublisher allows the agent to stream chunks to the Session Projector.
type StreamPublisher interface {
	PublishChunk(chunk AgentResponseChunk)
}
