package domains

import (
	"context"

	"github.com/pradigi/backend/internal/workbench/domain"
)

// ===========================
// Domain Adapter Contract
// Currently implemented as a compiled Go plugin, but strictly uses `Execute`
// so it can seamlessly transition to a remote gRPC/WASM plugin in the future.
// ===========================

type ExecuteRequest struct {
	MissionID string                 `json:"mission_id"`
	Action    string                 `json:"action"` // e.g. "RUN_CODE", "LINT"
	Payload   map[string]interface{} `json:"payload"`
}

type ExecuteResponse struct {
	Success bool                   `json:"success"`
	Output  string                 `json:"output"`
	Metrics map[string]interface{} `json:"metrics,omitempty"`
}

type DomainAdapter interface {
	// Initialize prepares the domain adapter for a new mission session.
	Initialize(ctx context.Context, mission *domain.Mission) error
	
	// Execute performs an action within the domain.
	// This abstract method replaces specific methods like RunPython() to ensure
	// gRPC compatibility.
	Execute(ctx context.Context, req *ExecuteRequest) (*ExecuteResponse, error)
	
	// Teardown cleans up resources after the mission session.
	Teardown(ctx context.Context, missionID string) error
}
