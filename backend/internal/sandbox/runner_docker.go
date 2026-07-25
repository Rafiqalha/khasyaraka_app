package sandbox

import (
	"bytes"
	"context"
	"fmt"
	"github.com/google/uuid"
	"os/exec"
	"strings"
	"time"
)

const (
	containerMemory = "50m"
	containerCPU    = "0.5"
)

type DockerRunner struct {
	id      string
	image   string
	created time.Time
}

func NewDockerRunner(ctx context.Context, image string) (*DockerRunner, error) {
	id := uuid.New().String()[:8]
	name := fmt.Sprintf("pradigi-sandbox-%s", id)

	// docker run -d -i --name name --memory 50m --cpus 0.5 --network none python:3.11-slim tail -f /dev/null
	args := []string{
		"run",
		"-d",
		"-i",
		"--name", name,
		"--memory", containerMemory,
		"--cpus", containerCPU,
		"--network", "none",
		image,
		"tail", "-f", "/dev/null",
	}

	cmd := exec.CommandContext(ctx, "docker", args...)
	if err := cmd.Run(); err != nil {
		return nil, fmt.Errorf("failed to spawn container %s: %w", name, err)
	}

	return &DockerRunner{
		id:      name,
		image:   image,
		created: time.Now(),
	}, nil
}

func (r *DockerRunner) GetLanguage() string {
	return "python"
}

func (r *DockerRunner) GetID() string {
	return r.id
}

func (r *DockerRunner) Destroy() error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	cmd := exec.CommandContext(ctx, "docker", "rm", "-f", r.id)
	return cmd.Run()
}

func (r *DockerRunner) HeartbeatLight(ctx context.Context) error {
	// Simple docker inspect to check if it's running
	cmd := exec.CommandContext(ctx, "docker", "inspect", "-f", "{{.State.Running}}", r.id)
	out, err := cmd.Output()
	if err != nil {
		return err
	}
	if strings.TrimSpace(string(out)) != "true" {
		return fmt.Errorf("container is not running")
	}
	return nil
}

func (r *DockerRunner) HeartbeatDeep(ctx context.Context) error {
	// Deep check: execute a simple python print
	cmd := exec.CommandContext(ctx, "docker", "exec", "-i", r.id, "python3", "-c", "print(1)")
	out, err := cmd.Output()
	if err != nil {
		return err
	}
	if strings.TrimSpace(string(out)) != "1" {
		return fmt.Errorf("deep heartbeat failed")
	}
	return nil
}

func (r *DockerRunner) Execute(ctx context.Context, req ExecutionRequest) (ExecutionResult, error) {
	start := time.Now()

	execCtx, cancel := context.WithTimeout(ctx, req.Timeout)
	defer cancel()

	// Use python3 - (reads from stdin)
	cmd := exec.CommandContext(execCtx, "docker", "exec", "-i", r.id, "python3", "-")

	// Pass code via stdin
	cmd.Stdin = strings.NewReader(req.Code)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()

	execTime := time.Since(start).Milliseconds()

	result := ExecutionResult{
		Stdout:        strings.TrimSpace(stdout.String()),
		Stderr:        strings.TrimSpace(stderr.String()),
		ExitCode:      0,
		ExecutionTime: int(execTime),
		MemoryUsage:   0,
		SandboxMetadata: SandboxMetadata{
			ContainerID:  r.id,
			ImageVersion: r.image,
		},
	}

	if err != nil {
		if execCtx.Err() == context.DeadlineExceeded {
			result.ExitCode = 124 // Timeout
			return result, nil
		}

		if exitError, ok := err.(*exec.ExitError); ok {
			result.ExitCode = exitError.ExitCode()
			return result, nil
		}

		return result, fmt.Errorf("docker exec failed: %w", err)
	}

	return result, nil
}
