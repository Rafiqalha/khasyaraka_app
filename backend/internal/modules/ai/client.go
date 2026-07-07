package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
)

type GeminiClient struct {
	apiKey     string
	model      string
	httpClient *http.Client
	baseURL    string
}

func NewGeminiClient(apiKey, model string) *GeminiClient {
	return &GeminiClient{
		apiKey:     apiKey,
		model:      model,
		httpClient: &http.Client{},
		baseURL:    "https://generativelanguage.googleapis.com/v1beta/models/",
	}
}

func (c *GeminiClient) Chat(ctx context.Context, systemPrompt, userMessage string, maxTokens int, temp float64) (string, error) {
	url := fmt.Sprintf("%s%s:generateContent?key=%s", c.baseURL, c.model, c.apiKey)

	reqBody := GeminiRequest{
		Contents: []GeminiContent{
			{
				Parts: []GeminiPart{
					{Text: userMessage},
				},
			},
		},
		SystemInstruction: &GeminiInstruction{
			Parts: []GeminiPart{
				{Text: systemPrompt},
			},
		},
		GenerationConfig: GeminiConfig{
			MaxOutputTokens: maxTokens,
			Temperature:     temp,
		},
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("gemini API error: status %d, body: %s", resp.StatusCode, string(bodyBytes))
	}

	var geminiResp GeminiResponse
	if err := json.Unmarshal(bodyBytes, &geminiResp); err != nil {
		return "", err
	}

	if len(geminiResp.Candidates) > 0 && len(geminiResp.Candidates[0].Content.Parts) > 0 {
		return geminiResp.Candidates[0].Content.Parts[0].Text, nil
	}

	return "", errors.New("empty response from gemini API")
}
