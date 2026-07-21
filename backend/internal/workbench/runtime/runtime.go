// Package runtime defines the universal Execution Runtime abstraction.
//
// Runtime is the layer between Workbench Tools/Adapters and the physical
// execution environment. Missions and Adapters never know HOW code is executed.
// They only interact through the canonical lifecycle:
//
//	Prepare() → Execute() → Observe() → Snapshot() → Cleanup()
//
// Implementations include:
//   - DockerRuntime (containers)
//   - FirecrackerRuntime (microVMs)
//   - WASMRuntime (browser sandboxes)
//   - NativeRuntime (local process)
//   - RemoteRuntime (cloud execution)
package runtime

import (
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"time"
)

// ===========================
// Runtime Capabilities
// Richer than Supports(language). Describes what the runtime CAN do.
// ===========================

type Capability string

const (
	CapNetwork    Capability = "NETWORK"
	CapFilesystem Capability = "FILESYSTEM"
	CapProcesses  Capability = "PROCESSES"
	CapCompiler   Capability = "COMPILER"
	CapGPU        Capability = "GPU"
	CapPackets    Capability = "PACKET_CAPTURE"
	CapTCP        Capability = "TCP"
	CapDNS        Capability = "DNS"
	CapDocker     Capability = "DOCKER"
	CapBrowser    Capability = "BROWSER"
	CapGit        Capability = "GIT"
)

// RuntimeInfo describes a Runtime's identity and capabilities.
type RuntimeInfo struct {
	Name         string       `json:"name"`
	Version      string       `json:"version"`
	Languages    []string     `json:"languages"`
	Capabilities []Capability `json:"capabilities"`
}

// ===========================
// Execution Request (Immutable + Fingerprinted)
// ===========================

type ExecutionRequest struct {
	// Identity
	SessionID string `json:"session_id"`
	MissionID string `json:"mission_id"`
	RequestID string `json:"request_id"`

	// What to execute
	Language   string            `json:"language"`
	SourceCode string            `json:"source_code"`
	EntryPoint string            `json:"entry_point"`
	Args       []string          `json:"args,omitempty"`
	Stdin      string            `json:"stdin,omitempty"`
	EnvVars    map[string]string `json:"env_vars,omitempty"`

	// Fixtures (injected files)
	Files map[string][]byte `json:"files,omitempty"`

	// Test suite (optional)
	TestFiles map[string][]byte `json:"test_files,omitempty"`
	TestCmd   string            `json:"test_cmd,omitempty"`

	// Resource Constraints
	TimeoutSeconds int    `json:"timeout_seconds"`
	MemoryLimitMB  int    `json:"memory_limit_mb"`
	CPULimit       string `json:"cpu_limit,omitempty"`
	NetworkEnabled bool   `json:"network_enabled"`
}

// Fingerprint produces a deterministic SHA-256 hash of the request content.
// Two identical requests always produce the same fingerprint.
// Used for execution caching and benchmarking reproducibility.
func (r *ExecutionRequest) Fingerprint() string {
	data, _ := json.Marshal(struct {
		Language   string            `json:"language"`
		SourceCode string            `json:"source_code"`
		EntryPoint string            `json:"entry_point"`
		Args       []string          `json:"args"`
		Stdin      string            `json:"stdin"`
		EnvVars    map[string]string `json:"env_vars"`
		TestCmd    string            `json:"test_cmd"`
	}{
		Language:   r.Language,
		SourceCode: r.SourceCode,
		EntryPoint: r.EntryPoint,
		Args:       r.Args,
		Stdin:      r.Stdin,
		EnvVars:    r.EnvVars,
		TestCmd:    r.TestCmd,
	})
	hash := sha256.Sum256(data)
	return fmt.Sprintf("%x", hash)
}

// ===========================
// Execution Result (Immutable Fact)
// This is a FACT — never modified after creation.
// Interpretation happens in ExecutionAssessment.
// ===========================

type ExecutionResult struct {
	RequestID    string `json:"request_id"`
	Fingerprint  string `json:"fingerprint"`
	Stdout       string `json:"stdout"`
	Stderr       string `json:"stderr"`
	ExitCode     int    `json:"exit_code"`
	DurationMs   int64  `json:"duration_ms"`
	MemoryUsedKB int64  `json:"memory_used_kb"`
	TestsPassed  int    `json:"tests_passed"`
	TestsFailed  int    `json:"tests_failed"`
	TestsTotal   int    `json:"tests_total"`
	CoveragePct  *float64     `json:"coverage_pct,omitempty"`
	FilesChanged []FileChange `json:"files_changed,omitempty"`
	TimedOut     bool   `json:"timed_out"`
	OOMKilled    bool   `json:"oom_killed"`
	Error        string `json:"error,omitempty"`
}

type FileChange struct {
	Path      string `json:"path"`
	Operation string `json:"operation"` // "CREATED", "MODIFIED", "DELETED"
	SizeBytes int64  `json:"size_bytes"`
}

// ===========================
// Execution Assessment (Interpretation of Result)
// Separate from Result — Result is fact, Assessment is judgment.
// Consistent with Canonical Learning Ontology.
// ===========================

type ExecutionAssessment struct {
	RequestID    string `json:"request_id"`
	SyntaxValid  bool   `json:"syntax_valid"`
	RuntimeClean bool   `json:"runtime_clean"`
	AllTestsPassed bool `json:"all_tests_passed"`
	TestsPassed  int    `json:"tests_passed"`
	TestsFailed  int    `json:"tests_failed"`
	TimedOut     bool   `json:"timed_out"`
	OOMKilled    bool   `json:"oom_killed"`
	Summary      string `json:"summary"`
}

// ===========================
// Execution Trace (Timeline Graph, not flat record)
// Each trace is a sequence of lifecycle events — not a single blob.
// ===========================

type TraceEventType string

const (
	TraceContainerCreated TraceEventType = "CONTAINER_CREATED"
	TraceFileMounted      TraceEventType = "FILE_MOUNTED"
	TraceExecutionStarted TraceEventType = "EXECUTION_STARTED"
	TraceStdoutProduced   TraceEventType = "STDOUT_PRODUCED"
	TraceStderrProduced   TraceEventType = "STDERR_PRODUCED"
	TraceExitReceived     TraceEventType = "EXIT_RECEIVED"
	TraceCleanupDone      TraceEventType = "CLEANUP_DONE"
)

type TraceEvent struct {
	RequestID   string         `json:"request_id"`
	EventType   TraceEventType `json:"event_type"`
	Detail      string         `json:"detail,omitempty"`
	OccurredAt  time.Time      `json:"occurred_at"`
	RelativeMs  int64          `json:"relative_ms"` // Since execution started
}

type ExecutionTrace struct {
	RequestID    string       `json:"request_id"`
	RuntimeType  string       `json:"runtime_type"`
	ContainerID  string       `json:"container_id,omitempty"`
	ImageUsed    string       `json:"image_used,omitempty"`
	CPUTimeMs    int64        `json:"cpu_time_ms"`
	MemoryPeakKB int64        `json:"memory_peak_kb"`
	NetworkInKB  int64        `json:"network_in_kb"`
	NetworkOutKB int64        `json:"network_out_kb"`
	FSDiffBytes  int64        `json:"fs_diff_bytes"`
	Events       []TraceEvent `json:"events"`
	StartedAt    time.Time    `json:"started_at"`
	FinishedAt   time.Time    `json:"finished_at"`
}

// ===========================
// Runtime Events (Event-Driven Lifecycle)
// Runtime emits events — Decision Graph and Cognitive Engine subscribe.
// ===========================

type RuntimeEventType string

const (
	RTEventPrepared        RuntimeEventType = "RuntimePrepared"
	RTEventExecutionStarted  RuntimeEventType = "ExecutionStarted"
	RTEventOutputProduced    RuntimeEventType = "ExecutionOutputProduced"
	RTEventExecutionCompleted RuntimeEventType = "ExecutionCompleted"
	RTEventSnapshotCaptured  RuntimeEventType = "SnapshotCaptured"
	RTEventCleaned           RuntimeEventType = "ExecutionCleaned"
)

// ===========================
// Execution Policy
// Decides WHICH runtime is ALLOWED for a given context.
// Adapter does not choose runtime. Policy does.
// ===========================

type ExecutionContext string

const (
	ContextEducation   ExecutionContext = "EDUCATION"
	ContextCompetition ExecutionContext = "COMPETITION"
	ContextAssessment  ExecutionContext = "ASSESSMENT"
	ContextResearch    ExecutionContext = "RESEARCH"
)

type PolicyRule struct {
	Context          ExecutionContext `json:"context"`
	AllowedRuntimes  []string         `json:"allowed_runtimes"` // runtime names
	MaxTimeoutSec    int              `json:"max_timeout_sec"`
	MaxMemoryMB      int              `json:"max_memory_mb"`
	NetworkAllowed   bool             `json:"network_allowed"`
}

type ExecutionPolicy interface {
	// Evaluate returns the PolicyRule for the given context.
	Evaluate(ctx context.Context, execCtx ExecutionContext, language string) (*PolicyRule, error)

	// SelectRuntime picks the best allowed runtime from the registry.
	SelectRuntime(ctx context.Context, rule *PolicyRule, registry *Registry) (Runtime, error)
}

type defaultPolicy struct {
	rules []PolicyRule
}

func NewDefaultPolicy() ExecutionPolicy {
	return &defaultPolicy{
		rules: []PolicyRule{
			{Context: ContextEducation, AllowedRuntimes: []string{"docker"}, MaxTimeoutSec: 30, MaxMemoryMB: 128, NetworkAllowed: false},
			{Context: ContextCompetition, AllowedRuntimes: []string{"docker", "firecracker"}, MaxTimeoutSec: 60, MaxMemoryMB: 256, NetworkAllowed: false},
			{Context: ContextAssessment, AllowedRuntimes: []string{"firecracker", "remote"}, MaxTimeoutSec: 120, MaxMemoryMB: 512, NetworkAllowed: false},
			{Context: ContextResearch, AllowedRuntimes: []string{"docker", "native"}, MaxTimeoutSec: 300, MaxMemoryMB: 1024, NetworkAllowed: true},
		},
	}
}

func (p *defaultPolicy) Evaluate(ctx context.Context, execCtx ExecutionContext, language string) (*PolicyRule, error) {
	for _, rule := range p.rules {
		if rule.Context == execCtx {
			return &rule, nil
		}
	}
	// Default to education
	return &p.rules[0], nil
}

func (p *defaultPolicy) SelectRuntime(ctx context.Context, rule *PolicyRule, registry *Registry) (Runtime, error) {
	for _, name := range rule.AllowedRuntimes {
		if rt := registry.FindByName(name); rt != nil {
			return rt, nil
		}
	}
	return nil, fmt.Errorf("no allowed runtime available for policy context")
}

// ===========================
// The Runtime Interface (Full Lifecycle)
//
//	Prepare() → Execute() → Observe() → Snapshot() → Cleanup()
//
// ===========================

type Runtime interface {
	// Info returns metadata and capabilities of this runtime.
	Info() RuntimeInfo

	// Prepare sets up the execution environment (pull image, mount files, create container).
	Prepare(ctx context.Context, req ExecutionRequest) error

	// Execute runs the request. Returns immutable fact.
	Execute(ctx context.Context, req ExecutionRequest) (*ExecutionResult, error)

	// Observe returns the execution trace timeline for the last execution.
	Observe(ctx context.Context, requestID string) (*ExecutionTrace, error)

	// Snapshot captures the current environment state (filesystem, processes).
	Snapshot(ctx context.Context, sessionID string) (map[string]any, error)

	// Cleanup releases all resources for a given session.
	Cleanup(ctx context.Context, sessionID string) error
}

// ===========================
// Runtime Registry (Plugin System)
// ===========================

type Registry struct {
	runtimes map[string]Runtime
}

func NewRegistry() *Registry {
	return &Registry{runtimes: make(map[string]Runtime)}
}

func (r *Registry) Register(rt Runtime) {
	r.runtimes[rt.Info().Name] = rt
}

func (r *Registry) Unregister(name string) {
	delete(r.runtimes, name)
}

func (r *Registry) FindByName(name string) Runtime {
	return r.runtimes[name]
}

func (r *Registry) ListRuntimes() []RuntimeInfo {
	infos := make([]RuntimeInfo, 0, len(r.runtimes))
	for _, rt := range r.runtimes {
		infos = append(infos, rt.Info())
	}
	return infos
}

// Resolve finds the first Runtime that supports the given language.
func (r *Registry) Resolve(language string) Runtime {
	for _, rt := range r.runtimes {
		for _, lang := range rt.Info().Languages {
			if lang == language {
				return rt
			}
		}
	}
	return nil
}
