package runtime

import (
	"context"
)

// ===========================
// Runtime Driver Abstraction
// Handles the low-level lifecycle of an isolated execution environment.
// Implementations: Docker, Firecracker, Browser, WASM, Kubernetes.
// ===========================

type RuntimeDriver interface {
	// Start provisions and boots up the environment.
	Start(ctx context.Context, config map[string]interface{}) (string, error)

	// Exec runs a raw command inside the environment.
	Exec(ctx context.Context, envID string, cmd []string) (string, error)

	// CopyTo moves files from the host into the environment.
	CopyTo(ctx context.Context, envID string, srcPath, destPath string) error

	// CopyFrom retrieves files from the environment to the host.
	CopyFrom(ctx context.Context, envID string, srcPath, destPath string) error

	// Stop tears down the environment.
	Stop(ctx context.Context, envID string) error
}
