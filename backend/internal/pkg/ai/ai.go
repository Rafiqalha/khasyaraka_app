package ai

import (
	"context"
	"time"
)

type TokenUsage struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
	TotalTokens      int `json:"total_tokens"`
}

type AIResponse struct {
	ID           string
	Raw          string
	Model        string
	Provider     string
	Latency      time.Duration
	Usage        TokenUsage
	Cost         float64
	FinishReason string
	CacheHit     bool
	RequestID    string
}

type Client interface {
	Generate(ctx context.Context, prompt string) (*AIResponse, error)
}

// MockClient for initial MVP
type mockClient struct {
	model    string
	provider string
}

func NewMockClient(model string) Client {
	return &mockClient{model: model, provider: "mock_provider"}
}

func (m *mockClient) Generate(ctx context.Context, prompt string) (*AIResponse, error) {
	// Simulate latency
	time.Sleep(100 * time.Millisecond)
	return &AIResponse{
		ID:  "resp_" + time.Now().Format("20060102150405"),
		Raw: `{"confidence": 0.85, "summary": "User shows signs of basic understanding.", "skills": [{"skill_id": "problem_solving", "direction": "POSITIVE", "strength": 0.6, "reason": "Tried multiple approaches."}]}`,
		Usage: TokenUsage{
			PromptTokens:     100,
			CompletionTokens: 50,
			TotalTokens:      150,
		},
		Cost:         0.0015,
		Latency:      100 * time.Millisecond,
		Model:        m.model,
		Provider:     m.provider,
		FinishReason: "stop",
		CacheHit:     false,
		RequestID:    "req_" + time.Now().Format("20060102150405"),
	}, nil
}
