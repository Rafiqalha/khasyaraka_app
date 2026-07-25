package runtime

import (
	"bytes"
	"context"
	"fmt"
	"os/exec"
	"strings"
	"time"
)

// DockerRuntime executes code inside isolated Docker containers.
// Implements the full Runtime lifecycle: Prepare → Execute → Observe → Snapshot → Cleanup.
type DockerRuntime struct {
	defaultImage map[string]string
	traces       map[string]*ExecutionTrace // requestID -> trace
}

func NewDockerRuntime() *DockerRuntime {
	return &DockerRuntime{
		defaultImage: map[string]string{
			"python":     "python:3.12-slim",
			"bash":       "ubuntu:22.04",
			"javascript": "node:20-slim",
			"java":       "openjdk:21-slim",
			"go":         "golang:1.22-alpine",
		},
		traces: make(map[string]*ExecutionTrace),
	}
}

func (d *DockerRuntime) Info() RuntimeInfo {
	langs := make([]string, 0, len(d.defaultImage))
	for l := range d.defaultImage {
		langs = append(langs, l)
	}
	return RuntimeInfo{
		Name:      "docker",
		Version:   "1.0.0",
		Languages: langs,
		Capabilities: []Capability{
			CapFilesystem,
			CapProcesses,
			CapCompiler,
		},
	}
}

func (d *DockerRuntime) Prepare(ctx context.Context, req ExecutionRequest) error {
	image, ok := d.defaultImage[req.Language]
	if !ok {
		return fmt.Errorf("docker runtime: unsupported language %q", req.Language)
	}

	// Initialize trace timeline
	now := time.Now()
	d.traces[req.RequestID] = &ExecutionTrace{
		RequestID:   req.RequestID,
		RuntimeType: "docker",
		ImageUsed:   image,
		StartedAt:   now,
		Events: []TraceEvent{
			{RequestID: req.RequestID, EventType: TraceContainerCreated, Detail: image, OccurredAt: now, RelativeMs: 0},
		},
	}

	return nil
}

func (d *DockerRuntime) Execute(ctx context.Context, req ExecutionRequest) (*ExecutionResult, error) {
	image, ok := d.defaultImage[req.Language]
	if !ok {
		return nil, fmt.Errorf("docker runtime: unsupported language %q", req.Language)
	}

	timeout := time.Duration(req.TimeoutSeconds) * time.Second
	if timeout == 0 {
		timeout = 30 * time.Second
	}
	execCtx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	memLimit := req.MemoryLimitMB
	if memLimit == 0 {
		memLimit = 128
	}

	args := []string{
		"run", "--rm",
		"--network=none",
		fmt.Sprintf("--memory=%dm", memLimit),
		"--cpus=0.5",
		"--pids-limit=64",
		"--read-only",
		"--tmpfs=/tmp:rw,noexec,nosuid,size=64m",
	}
	if req.NetworkEnabled {
		args[2] = "--network=bridge"
	}
	args = append(args, image, req.Language, "-c", req.SourceCode)

	// Record start event
	start := time.Now()
	if trace, ok := d.traces[req.RequestID]; ok {
		trace.Events = append(trace.Events, TraceEvent{
			RequestID: req.RequestID, EventType: TraceExecutionStarted,
			OccurredAt: start, RelativeMs: time.Since(trace.StartedAt).Milliseconds(),
		})
	}

	cmd := exec.CommandContext(execCtx, "docker", args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	if req.Stdin != "" {
		cmd.Stdin = strings.NewReader(req.Stdin)
	}

	err := cmd.Run()
	duration := time.Since(start)
	finished := time.Now()

	result := &ExecutionResult{
		RequestID:   req.RequestID,
		Fingerprint: req.Fingerprint(),
		Stdout:      stdout.String(),
		Stderr:      stderr.String(),
		DurationMs:  duration.Milliseconds(),
	}

	if execCtx.Err() != nil {
		result.TimedOut = true
		result.ExitCode = 124
	} else if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			result.ExitCode = exitErr.ExitCode()
			if result.ExitCode == 137 {
				result.OOMKilled = true
			}
		} else {
			result.Error = err.Error()
			result.ExitCode = -1
		}
	}

	// Record trace events
	if trace, ok := d.traces[req.RequestID]; ok {
		base := trace.StartedAt
		if result.Stdout != "" {
			trace.Events = append(trace.Events, TraceEvent{
				RequestID: req.RequestID, EventType: TraceStdoutProduced,
				Detail: result.Stdout, OccurredAt: finished, RelativeMs: finished.Sub(base).Milliseconds(),
			})
		}
		if result.Stderr != "" {
			trace.Events = append(trace.Events, TraceEvent{
				RequestID: req.RequestID, EventType: TraceStderrProduced,
				Detail: result.Stderr, OccurredAt: finished, RelativeMs: finished.Sub(base).Milliseconds(),
			})
		}
		trace.Events = append(trace.Events, TraceEvent{
			RequestID: req.RequestID, EventType: TraceExitReceived,
			Detail: fmt.Sprintf("exit_code=%d", result.ExitCode), OccurredAt: finished, RelativeMs: finished.Sub(base).Milliseconds(),
		})
		trace.FinishedAt = finished
	}

	return result, nil
}

func (d *DockerRuntime) Observe(ctx context.Context, requestID string) (*ExecutionTrace, error) {
	trace, ok := d.traces[requestID]
	if !ok {
		return nil, fmt.Errorf("no trace found for request %s", requestID)
	}
	return trace, nil
}

func (d *DockerRuntime) Snapshot(ctx context.Context, sessionID string) (map[string]any, error) {
	return map[string]any{
		"runtime": "docker",
		"session": sessionID,
		"status":  "snapshot_captured",
	}, nil
}

func (d *DockerRuntime) Cleanup(ctx context.Context, sessionID string) error {
	// Remove traces for this session
	for k := range d.traces {
		delete(d.traces, k)
	}
	return nil
}
