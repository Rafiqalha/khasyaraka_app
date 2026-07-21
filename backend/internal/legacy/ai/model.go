package ai

type ChatRequest struct {
	Prompt string `json:"prompt" binding:"required,max=500"`
}

type ChatResponse struct {
	Response        string `json:"response"`
	TokensRemaining int    `json:"tokens_remaining"`
	CipherMood      string `json:"cipher_mood"`
}

type GeminiRequest struct {
	Contents          []GeminiContent    `json:"contents"`
	SystemInstruction *GeminiInstruction `json:"systemInstruction,omitempty"`
	GenerationConfig  GeminiConfig       `json:"generationConfig"`
}

type GeminiContent struct {
	Parts []GeminiPart `json:"parts"`
}

type GeminiInstruction struct {
	Parts []GeminiPart `json:"parts"`
}

type GeminiPart struct {
	Text string `json:"text"`
}

type GeminiConfig struct {
	MaxOutputTokens int     `json:"maxOutputTokens"`
	Temperature     float64 `json:"temperature"`
}

type GeminiResponse struct {
	Candidates []GeminiCandidate `json:"candidates"`
}

type GeminiCandidate struct {
	Content GeminiContent `json:"content"`
}
