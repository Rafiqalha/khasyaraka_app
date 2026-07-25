package services

import (
	"context"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

type AIService struct{}

func NewAIService() *AIService {
	return &AIService{}
}

func (s *AIService) ID() string {
	return "ai_service"
}

func (s *AIService) Initialize(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("AIService initialized")
	return nil
}

func (s *AIService) Execute(ctx kernel.RuntimeContext) error {
	return nil
}

func (s *AIService) Shutdown(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("AIService shutdown")
	return nil
}

// GenerateHint is a specific Service API exposing AI generation capability
func (s *AIService) GenerateHint(ctx kernel.RuntimeContext, query string) error {
	// Call LLM
	response := "Try using a for-loop to iterate through the array." // mock

	// Emit continuous evidence of a hint request
	if err := ctx.Emit(context.Background(), "HINT_GENERATED", map[string]string{"query": query, "response": response}); err != nil {
		return err
	}
	return nil
}
