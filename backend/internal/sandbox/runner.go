package sandbox

import (
	"context"
	"time"
)

// SandboxMetadata tracks the container environment
type SandboxMetadata struct {
	ContainerID  string `json:"containerId"`
	ImageVersion string `json:"imageVersion"`
}

// ExecutionResult contains the output and metrics of a run
type ExecutionResult struct {
	Stdout          string          `json:"stdout"`
	Stderr          string          `json:"stderr"`
	ExitCode        int             `json:"exitCode"`
	ExecutionTime   int             `json:"executionTime"` // in ms
	MemoryUsage     int             `json:"memoryUsage"`   // in kb
	SandboxMetadata SandboxMetadata `json:"sandboxMetadata"`
}

// ExecutionRequest contains parameters for sandbox execution
type ExecutionRequest struct {
	Code     string
	Language string
	Timeout  time.Duration
}

// Runner defines the interface for language-specific sandboxes
type Runner interface {
	Execute(ctx context.Context, req ExecutionRequest) (ExecutionResult, error)
	GetLanguage() string
	GetID() string
	Destroy() error
	HeartbeatLight(ctx context.Context) error
	HeartbeatDeep(ctx context.Context) error
}

// RunnerPool manages a pool of runners to avoid constant container creation overhead
type RunnerPool interface {
	Acquire(ctx context.Context, language string) (Runner, error)
	Release(Runner)
	Metrics() PoolMetrics
}

type PoolMetrics struct {
	Idle           int     `json:"idle"`
	Busy           int     `json:"busy"`
	Draining       int     `json:"draining"`
	Creating       int     `json:"creating"`
	AvgAcquireMs   int     `json:"avgAcquireMs"`
	AvgExecutionMs int     `json:"avgExecutionMs"`
	P95ExecutionMs int     `json:"p95ExecutionMs"`
	P99ExecutionMs int     `json:"p99ExecutionMs"`
	FailureRate    float64 `json:"failureRate"`
	TimeoutRate    float64 `json:"timeoutRate"`
}
