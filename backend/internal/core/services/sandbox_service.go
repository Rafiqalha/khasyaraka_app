package services

import (
	"context"
	"fmt"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

type SandboxService struct{}

func NewSandboxService() *SandboxService {
	return &SandboxService{}
}

func (s *SandboxService) ID() string {
	return "sandbox_service"
}

func (s *SandboxService) Initialize(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("SandboxService initialized")
	return nil
}

func (s *SandboxService) Execute(ctx kernel.RuntimeContext) error {
	// E.g. trigger container spin up
	return ctx.Emit(context.Background(), "SANDBOX_READY", map[string]string{"status": "ready"})
}

func (s *SandboxService) Shutdown(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("SandboxService shutdown")
	return nil
}

// RunCode represents an API exposed by this service to be triggered externally (e.g., HTTP handler routing here)
func (s *SandboxService) RunCode(ctx kernel.RuntimeContext, code string) error {
	// Execute code via Firecracker/Docker...
	output := "Executed successfully: " + code // mock

	// Emit continuous evidence!
	if err := ctx.Emit(context.Background(), "CODE_EXECUTED", map[string]string{"output": output}); err != nil {
		return fmt.Errorf("emit CODE_EXECUTED: %w", err)
	}

	return nil
}
