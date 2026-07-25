package director

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

// FeedbackObject represents the structured AI analysis returned to the user
type FeedbackObject struct {
	Diagnosis  string   `json:"diagnosis"`
	Suggestion string   `json:"suggestion"`
	References []string `json:"references"`
	Confidence float64  `json:"confidence"`
}

type TutorService struct {
	apiKey     string
	model      string
	httpClient *http.Client
	baseURL    string
}

func NewTutorService(apiKey string, modelName string) (*TutorService, error) {
	if modelName == "" || strings.Contains(strings.ToLower(modelName), "gemini") {
		modelName = "deepseek-coder" // default to deepseek coder
	}
	return &TutorService{
		apiKey:     apiKey,
		model:      modelName,
		httpClient: &http.Client{},
		baseURL:    "https://api.deepseek.com/chat/completions",
	}, nil
}

func (s *TutorService) AnalyzeError(ctx context.Context, code string, stderr string) (*FeedbackObject, error) {
	systemPrompt := `You are an expert AI Tutor. Analyze the user's code execution error.
Return ONLY a raw JSON object with no markdown formatting and no backticks. The JSON must have these exact fields:
- "diagnosis": a concise explanation of why the error occurred.
- "suggestion": a concise actionable advice to fix it.
- "references": an array of strings (e.g. documentation topics).
- "confidence": a float between 0.0 and 1.0.`

	userMessage := fmt.Sprintf("Code:\n%s\n\nError (stderr):\n%s", code, stderr)

	reqBody := map[string]interface{}{
		"model": s.model,
		"messages": []map[string]interface{}{
			{"role": "system", "content": systemPrompt},
			{"role": "user", "content": userMessage},
		},
		"response_format": map[string]interface{}{
			"type": "json_object",
		},
		"temperature": 0.2,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", s.baseURL, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.apiKey)

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("deepseek API error: status %d, body: %s", resp.StatusCode, string(bodyBytes))
	}

	var deepseekResp struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}

	if err := json.Unmarshal(bodyBytes, &deepseekResp); err != nil {
		return nil, err
	}

	if len(deepseekResp.Choices) == 0 || deepseekResp.Choices[0].Message.Content == "" {
		return nil, fmt.Errorf("empty response from deepseek API")
	}

	text := deepseekResp.Choices[0].Message.Content
	text = strings.TrimSpace(text)
	text = strings.TrimPrefix(text, "```json")
	text = strings.TrimPrefix(text, "```")
	text = strings.TrimSuffix(text, "```")
	text = strings.TrimSpace(text)

	var feedback FeedbackObject
	if err := json.Unmarshal([]byte(text), &feedback); err != nil {
		// Fallback if AI fails to return valid JSON
		return &FeedbackObject{
			Diagnosis:  "System encountered an error parsing the diagnosis.",
			Suggestion: "Check the raw console output.",
			References: []string{},
			Confidence: 0.0,
		}, nil
	}

	return &feedback, nil
}
