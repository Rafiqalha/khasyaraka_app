package ai

import (
	"context"
	"errors"

	"github.com/khasyaraka/backend/internal/modules/token"
)

type AIService struct {
	client       *GeminiClient
	tokenService *token.TokenService
	maxTokens    int
	temperature  float64
}

func NewAIService(client *GeminiClient, tokenService *token.TokenService, maxTokens int, temperature float64) *AIService {
	return &AIService{
		client:       client,
		tokenService: tokenService,
		maxTokens:    maxTokens,
		temperature:  temperature,
	}
}

func (s *AIService) Chat(ctx context.Context, userID int64, prompt string) (*ChatResponse, error) {
	if prompt == "" {
		return nil, errors.New("prompt cannot be empty")
	}
	if len(prompt) > 500 {
		return nil, errors.New("prompt is too long (max 500 characters)")
	}

	// Consume token
	status, err := s.tokenService.ConsumeOne(ctx, userID)
	if err != nil {
		return nil, errors.New("TOKEN_EXHAUSTED")
	}

	// Call AI
	aiResponse, aiErr := s.client.Chat(ctx, CIPHER_SYSTEM_PROMPT, prompt, s.maxTokens, s.temperature)
	if aiErr != nil {
		s.tokenService.RefundOne(ctx, userID)
		return nil, errors.New("AI_ERROR")
	}

	mood := "strict"
	if status.Remaining >= 5 {
		mood = "encouraging"
	} else if status.Remaining >= 2 {
		mood = "warning"
	}

	return &ChatResponse{
		Response:        aiResponse,
		TokensRemaining: status.Remaining,
		CipherMood:      mood,
	}, nil
}

func (s *AIService) ChatWithCustomPrompt(ctx context.Context, userID int64, systemPrompt, prompt string) (*ChatResponse, error) {
	if prompt == "" {
		return nil, errors.New("prompt cannot be empty")
	}
	if len(prompt) > 500 {
		return nil, errors.New("prompt is too long (max 500 characters)")
	}

	// Consume token
	status, err := s.tokenService.ConsumeOne(ctx, userID)
	if err != nil {
		return nil, errors.New("TOKEN_EXHAUSTED")
	}

	// Call AI
	aiResponse, aiErr := s.client.Chat(ctx, systemPrompt, prompt, s.maxTokens, s.temperature)
	if aiErr != nil {
		s.tokenService.RefundOne(ctx, userID)
		return nil, errors.New("AI_ERROR")
	}

	mood := "strict"
	if status.Remaining >= 5 {
		mood = "encouraging"
	} else if status.Remaining >= 2 {
		mood = "warning"
	}

	return &ChatResponse{
		Response:        aiResponse,
		TokensRemaining: status.Remaining,
		CipherMood:      mood,
	}, nil
}
