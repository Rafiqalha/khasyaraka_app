package ai_agent

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/pradigi/backend/internal/sandbox"
)

const (
	deepseekEndpoint  = "https://api.deepseek.com/chat/completions"
	defaultModel      = "deepseek-chat"
	requestTimeout    = 30 * time.Second
	maxTokens         = 2048
	temperature       = 0.7
	maxAgentIteration = 5
)

var (
	ErrAPIError        = errors.New("deepseek API returned non-200 status")
	ErrEmptyChoice     = errors.New("deepseek response has no choices")
	ErrInvalidJSON     = errors.New("AI output is not valid JSON after markdown stripping")
	ErrHTTPRequest     = errors.New("deepseek HTTP request failed")
	ErrReadBody        = errors.New("failed to read deepseek response body")
	ErrMaxIteration    = errors.New("agent reached maximum iterations without final answer")
	ErrAgentTimedOut   = errors.New("agent loop timed out")
)

type Client struct {
	apiKey     string
	model      string
	httpClient *http.Client
}

func NewClient(apiKey, model string) *Client {
	if model == "" {
		model = defaultModel
	}
	return &Client{
		apiKey: apiKey,
		model:  model,
		httpClient: &http.Client{
			Timeout: requestTimeout,
		},
	}
}

func (c *Client) chat(ctx context.Context, messages []Message) (string, *Usage, error) {
	reqBody := ChatCompletionsRequest{
		Model:       c.model,
		Messages:    messages,
		Temperature: temperature,
		MaxTokens:   maxTokens,
	}

	jsonReq, err := json.Marshal(reqBody)
	if err != nil {
		return "", nil, fmt.Errorf("marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, deepseekEndpoint, bytes.NewBuffer(jsonReq))
	if err != nil {
		return "", nil, fmt.Errorf("%w: %w", ErrHTTPRequest, err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+c.apiKey)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", nil, fmt.Errorf("%w: %w", ErrHTTPRequest, err)
	}
	defer resp.Body.Close()

	rawBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", nil, fmt.Errorf("%w: %w", ErrReadBody, err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", nil, fmt.Errorf("%w: status %d, body: %s", ErrAPIError, resp.StatusCode, string(rawBody))
	}

	var chatResp ChatCompletionsResponse
	if err := json.Unmarshal(rawBody, &chatResp); err != nil {
		return "", nil, fmt.Errorf("unmarshal deepseek response: %w", err)
	}

	if len(chatResp.Choices) == 0 {
		return "", nil, ErrEmptyChoice
	}

	return chatResp.Choices[0].Message.Content, &chatResp.Usage, nil
}

func (c *Client) Chat(ctx context.Context, messages []Message) (string, *Usage, error) {
	return c.chat(ctx, messages)
}

type Agent struct {
	client *Client
}

func NewAgent(client *Client) *Agent {
	return &Agent{client: client}
}

func (a *Agent) Execute(userContext string, history []Message) (*PradigiResponse, *TokenUsageTracker, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()

	messages := a.buildMessages(userContext, history)
	totalUsage := &TokenUsageTracker{}

	for i := 0; i < maxAgentIteration; i++ {
		select {
		case <-ctx.Done():
			return nil, totalUsage, ErrAgentTimedOut
		default:
		}

		aiContent, usage, err := a.client.chat(ctx, messages)
		if err != nil {
			return nil, totalUsage, err
		}

		totalUsage.PromptTokens += usage.PromptTokens
		totalUsage.CompletionTokens += usage.CompletionTokens

		action, isAction := a.parseAction(aiContent)
		if isAction && action.Action == "exec" && action.Command != "" {
			output, execErr := sandbox.ExecuteCommand(action.Command)
			observation := fmt.Sprintf("COMMAND: %s\nEXIT_CODE: ", action.Command)
			if execErr != nil {
				observation += "error\nSTDERR: " + output
			} else {
				observation += "0\nOUTPUT:\n" + output
			}

			messages = append(messages,
				Message{Role: "assistant", Content: aiContent},
				Message{Role: "user", Content: observation},
			)
			continue
		}

		cleanJSON := stripMarkdownJSON(aiContent)
		var pradigiResp PradigiResponse
		if err := json.Unmarshal([]byte(cleanJSON), &pradigiResp); err != nil {
			messages = append(messages,
				Message{Role: "assistant", Content: aiContent},
				Message{Role: "user", Content: "ERROR: Output tidak sesuai format JSON yang diminta. Tolong keluarkan PradigiResponse JSON yang valid."},
			)
			continue
		}

		return &pradigiResp, totalUsage, nil
	}

	return nil, totalUsage, ErrMaxIteration
}

func (a *Agent) buildMessages(userContext string, history []Message) []Message {
	messages := make([]Message, 0, len(history)+2)
	messages = append(messages, Message{Role: "system", Content: MasterSystemPrompt})
	messages = append(messages, history...)
	messages = append(messages, Message{Role: "user", Content: userContext})
	return messages
}

func (a *Agent) parseAction(content string) (*ToolAction, bool) {
	clean := stripMarkdownJSON(strings.TrimSpace(content))

	var action ToolAction
	if err := json.Unmarshal([]byte(clean), &action); err != nil {
		return nil, false
	}

	if action.Action == "exec" && action.Command != "" {
		return &action, true
	}

	return nil, false
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
