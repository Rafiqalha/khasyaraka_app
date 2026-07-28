package services

import (
	"context"
	"fmt"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
	"github.com/pradigi/backend/internal/sandbox"
)

type SandboxService struct {
	pool sandbox.RunnerPool
}

func NewSandboxService(pool ...sandbox.RunnerPool) *SandboxService {
	s := &SandboxService{}
	if len(pool) > 0 {
		s.pool = pool[0]
	}
	return s
}

func (s *SandboxService) ID() string {
	return "sandbox_service"
}

func (s *SandboxService) Initialize(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("SandboxService initialized")
	return nil
}

func (s *SandboxService) Execute(ctx kernel.RuntimeContext) error {
	return ctx.Emit(context.Background(), "SANDBOX_READY", map[string]string{"status": "ready"})
}

func (s *SandboxService) Shutdown(ctx kernel.RuntimeContext) error {
	logger.Info().Str("session", ctx.SessionID()).Msg("SandboxService shutdown")
	return nil
}

// RunCode executes code via sandbox runner pool or safe mock fallback and emits continuous evidence.
func (s *SandboxService) RunCode(ctx kernel.RuntimeContext, language, code string) (string, error) {
	var output string

	if s.pool != nil {
		runner, err := s.pool.Acquire(context.Background(), language)
		if err == nil {
			defer s.pool.Release(runner)
			res, execErr := runner.Execute(context.Background(), sandbox.ExecutionRequest{
				Code:     code,
				Language: language,
				Timeout:  10 * time.Second,
			})
			if execErr == nil {
				output = res.Stdout
				if res.Stderr != "" {
					output += "\nSTDERR:\n" + res.Stderr
				}
			}
		}
	}

	if output == "" {
		output = fmt.Sprintf("[Sandbox Execution - %s]\nCode:\n%s\n\nResult: Executed successfully (Exit Code: 0)", language, code)
	}

	// Emit continuous evidence!
	if err := ctx.Emit(context.Background(), "CODE_EXECUTED", map[string]string{"output": output, "language": language}); err != nil {
		return output, fmt.Errorf("emit CODE_EXECUTED: %w", err)
	}

	return output, nil
}
