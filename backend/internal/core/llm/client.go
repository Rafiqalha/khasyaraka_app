package llm

import (
	"context"
)

// Client is the interface that all LLM providers (DeepSeek, Gemini, etc.) must implement.
// This ensures that the AI Director and other consumers are completely decoupled from the provider.
type Client interface {
	// GenerateJSON sends a prompt and a strict JSON schema requirement to the LLM.
	// The LLM must return a raw JSON string that matches the schema.
	// It also returns the number of tokens used and latency for telemetry.
	GenerateJSON(ctx context.Context, systemPrompt string, userPrompt string) (jsonStr string, tokensIn int, tokensOut int, err error)
}
