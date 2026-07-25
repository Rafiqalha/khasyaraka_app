package deepseek

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/pradigi/backend/internal/core/llm"
)

type Adapter struct {
	apiKey     string
	model      string
	httpClient *http.Client
	baseURL    string
}

// NewAdapter creates a new DeepSeek LLM adapter.
func NewAdapter(apiKey string, modelName string) llm.Client {
	if modelName == "" {
		modelName = "deepseek-v4-flash"
	}
	return &Adapter{
		apiKey: apiKey,
		model:  modelName,
		httpClient: &http.Client{
			Timeout: 100 * time.Second,
		},
		baseURL: "https://api.deepseek.com/chat/completions",
	}
}

func (a *Adapter) GenerateJSON(ctx context.Context, systemPrompt string, userPrompt string) (string, int, int, error) {
	reqBody := map[string]interface{}{
		"model": a.model,
		"messages": []map[string]interface{}{
			{"role": "system", "content": systemPrompt},
			{"role": "user", "content": userPrompt},
		},
		"response_format": map[string]interface{}{
			"type": "json_object",
		},
		"temperature": 0.2, // Low temperature for deterministic JSON output
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", 0, 0, err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", a.baseURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", 0, 0, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+a.apiKey)

	resp, err := a.httpClient.Do(req)
	if err != nil {
		return "", 0, 0, err
	}
	defer resp.Body.Close()

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", 0, 0, err
	}

	if resp.StatusCode != http.StatusOK {
		return "", 0, 0, fmt.Errorf("deepseek API error: status %d, body: %s", resp.StatusCode, string(bodyBytes))
	}

	var deepseekResp struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
		Usage struct {
			PromptTokens     int `json:"prompt_tokens"`
			CompletionTokens int `json:"completion_tokens"`
		} `json:"usage"`
	}

	if err := json.Unmarshal(bodyBytes, &deepseekResp); err != nil {
		return "", 0, 0, err
	}

	if len(deepseekResp.Choices) == 0 || deepseekResp.Choices[0].Message.Content == "" {
		return "", 0, 0, fmt.Errorf("empty response from deepseek API")
	}

	text := deepseekResp.Choices[0].Message.Content
	text = strings.TrimSpace(text)
	text = strings.TrimPrefix(text, "```json")
	text = strings.TrimPrefix(text, "```")
	text = strings.TrimSuffix(text, "```")
	text = strings.TrimSpace(text)

	return text, deepseekResp.Usage.PromptTokens, deepseekResp.Usage.CompletionTokens, nil
}
