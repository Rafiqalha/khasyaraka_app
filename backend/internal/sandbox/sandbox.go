package sandbox

import (
	"bytes"
	"context"
	"fmt"
	"os/exec"
	"strings"
	"time"
)

const (
	executionTimeout = 5 * time.Second
	dockerImage      = "alpine:latest"
	containerMemory  = "50m"
	containerCPU     = "0.5"
)

var (
	ErrTimeout = fmt.Errorf("execution timed out after %v", executionTimeout)
)

func ExecuteCommand(command string) (string, error) {
	args := []string{
		"run",
		"--rm",
		"--network", "none",
		"--memory", containerMemory,
		"--cpus", containerCPU,
		dockerImage,
		"sh", "-c", command,
	}

	ctx, cancel := context.WithTimeout(context.Background(), executionTimeout)
	defer cancel()

	cmd := exec.CommandContext(ctx, "docker", args...)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	if err := cmd.Run(); err != nil {
		if ctx.Err() == context.DeadlineExceeded {
			return "Timeout Execution", ErrTimeout
		}
		return "", fmt.Errorf("docker exec failed: %w", err)
	}

	output := stdout.String() + stderr.String()
	return strings.TrimSpace(output), nil
}
