package blueprint

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/pradigi/backend/internal/cyberscraper"
)

const (
	deepseekEndpoint = "https://api.deepseek.com/chat/completions"
	requestTimeout   = 90 * time.Second
	maxTokens        = 8192
	temperature      = 0.8
)

type GeneratedBatch struct {
	SourceURL     string              `json:"source_url"`
	SourceArticle string              `json:"source_article"`
	Questions     []GeneratedQuestion `json:"questions"`
}

type GeneratedQuestion struct {
	Type            string                 `json:"type"`
	Question        string                 `json:"question"`
	Payload         map[string]interface{} `json:"payload"`
	DifficultyLevel int                    `json:"difficulty_level"`
	XP              int                    `json:"xp"`
}

type Generator struct {
	apiKey     string
	model      string
	httpClient *http.Client
}

func NewGenerator(apiKey, model string) *Generator {
	if model == "" {
		model = "deepseek-chat"
	}
	return &Generator{
		apiKey: apiKey,
		model:  model,
		httpClient: &http.Client{
			Timeout: requestTimeout,
		},
	}
}

func (g *Generator) Generate(ctx context.Context, articles []cyberscraper.NewsArticle) ([]GeneratedBatch, error) {
	if len(articles) == 0 {
		return nil, nil
	}

	articlesJSON, err := json.MarshalIndent(articles, "", "  ")
	if err != nil {
		return nil, fmt.Errorf("marshal articles: %w", err)
	}

	userPrompt := fmt.Sprintf(
		"Berita insiden siber terbaru:\n\n%s\n\nGenerasikan soal lab untuk SETIAP berita di atas.",
		string(articlesJSON),
	)

	messages := []map[string]string{
		{"role": "system", "content": BlueprintSystemPrompt},
		{"role": "user", "content": userPrompt},
	}

	reqBody := map[string]interface{}{
		"model":       g.model,
		"messages":    messages,
		"temperature": temperature,
		"max_tokens":  maxTokens,
	}

	jsonReq, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, deepseekEndpoint, bytes.NewBuffer(jsonReq))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+g.apiKey)

	resp, err := g.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("deepseek call: %w", err)
	}
	defer resp.Body.Close()

	rawBody, err := io.ReadAll(io.LimitReader(resp.Body, 2<<20))
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("deepseek returned status %d: %s", resp.StatusCode, string(rawBody[:min(500, len(rawBody))]))
	}

	var chatResp struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if err := json.Unmarshal(rawBody, &chatResp); err != nil {
		return nil, fmt.Errorf("parse deepseek response: %w", err)
	}

	if len(chatResp.Choices) == 0 {
		return nil, fmt.Errorf("deepseek returned empty choices")
	}

	content := stripMarkdownJSON(chatResp.Choices[0].Message.Content)

	var batches []GeneratedBatch
	if err := json.Unmarshal([]byte(content), &batches); err != nil {
		return nil, fmt.Errorf("parse generated questions: %w\nraw content: %.200s...", err, content)
	}

	return batches, nil
}

func stripMarkdownJSON(raw string) string {
	s := strings.TrimSpace(raw)
	if strings.HasPrefix(s, "```json") {
		s = strings.TrimPrefix(s, "```json")
		if idx := strings.LastIndex(s, "```"); idx != -1 {
			s = strings.TrimSpace(s[:idx])
		}
	} else if strings.HasPrefix(s, "```") {
		start := strings.Index(s, "\n")
		if start != -1 {
			s = s[start+1:]
		}
		if idx := strings.LastIndex(s, "```"); idx != -1 {
			s = strings.TrimSpace(s[:idx])
		}
	}
	return s
}
