package mission_engine

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/pkg/logger"
)

type ProcessState string

const (
	ProcessQueued     ProcessState = "QUEUED"
	ProcessReady      ProcessState = "READY"
	ProcessRunning    ProcessState = "RUNNING"
	ProcessBlocked    ProcessState = "BLOCKED"
	ProcessCheckpoint ProcessState = "CHECKPOINTED"
	ProcessFailed     ProcessState = "FAILED"
	ProcessRecovering ProcessState = "RECOVERING"
	ProcessCompleted  ProcessState = "COMPLETED"
	ProcessTerminated ProcessState = "TERMINATED"
)

type Checkpoint struct {
	CheckpointID string            `json:"checkpoint_id"`
	PID          string            `json:"pid"`
	Timestamp    time.Time         `json:"timestamp"`
	StateData    map[string]string `json:"state_data"`
}

// MissionProcess represents a Linux-like learning process in the OS Kernel.
type MissionProcess struct {
	PID          string         `json:"pid"`
	ParentPID    string         `json:"parent_pid,omitempty"` // Non-empty if forked from a parent process
	MissionID    string         `json:"mission_id"`
	Version      string         `json:"version"`
	State        ProcessState   `json:"state"`
	Dependencies []string       `json:"dependencies"` // PIDs that must COMPLETE before this PID can transition to READY
	Attempt      int            `json:"attempt"`
	MaxAttempts  int            `json:"max_attempts"`
	Checkpoints  []*Checkpoint  `json:"checkpoints"`
	ContextData  map[string]any `json:"context_data"`
}

const (
	EventProcessSpawned      = "MissionProcessSpawned"
	EventProcessCheckpointed = "MissionProcessCheckpointed"
	EventProcessRollback     = "MissionProcessRollback"
	EventProcessForked       = "MissionProcessForked"
	EventProcessRecovered    = "MissionProcessRecovered"
)

// MissionKernel acts as a Linux-like OS Kernel for learning processes.
// BOUNDARY RULE: Manages process queues, dependencies, checkpoints, rollbacks, and recovery/forking without AI dependencies.
type MissionKernel struct {
	processes map[string]*MissionProcess // Keyed by PID
	bus       kernel.EventBus
	mu        sync.RWMutex
}

func NewMissionKernel(bus kernel.EventBus) *MissionKernel {
	return &MissionKernel{
		processes: make(map[string]*MissionProcess),
		bus:       bus,
	}
}

func (k *MissionKernel) Spawn(missionID, version string, deps []string, maxAttempts int) (*MissionProcess, error) {
	k.mu.Lock()
	defer k.mu.Unlock()

	pid := fmt.Sprintf("pid_%d", time.Now().UnixNano())
	proc := &MissionProcess{
		PID:          pid,
		MissionID:    missionID,
		Version:      version,
		State:        ProcessQueued,
		Dependencies: deps,
		Attempt:      1,
		MaxAttempts:  maxAttempts,
		Checkpoints:  make([]*Checkpoint, 0),
		ContextData:  make(map[string]any),
	}

	if len(deps) == 0 {
		proc.State = ProcessReady
	}

	k.processes[pid] = proc
	logger.Info().Str("pid", pid).Str("mission", missionID).Str("state", string(proc.State)).Msg("Mission Kernel spawned learning process")

	k.emitEvent(context.Background(), EventProcessSpawned, proc)
	return proc, nil
}

func (k *MissionKernel) CheckpointProcess(pid string, stateData map[string]string) (*Checkpoint, error) {
	k.mu.Lock()
	defer k.mu.Unlock()

	proc, exists := k.processes[pid]
	if !exists {
		return nil, fmt.Errorf("process not found in kernel: %s", pid)
	}

	cp := &Checkpoint{
		CheckpointID: fmt.Sprintf("chk_%d", time.Now().UnixNano()),
		PID:          pid,
		Timestamp:    time.Now(),
		StateData:    stateData,
	}

	proc.Checkpoints = append(proc.Checkpoints, cp)
	proc.State = ProcessCheckpoint
	logger.Info().Str("pid", pid).Str("checkpoint", cp.CheckpointID).Msg("Mission Kernel created process checkpoint")

	k.emitEvent(context.Background(), EventProcessCheckpointed, cp)
	return cp, nil
}

func (k *MissionKernel) RollbackProcess(pid, checkpointID string) error {
	k.mu.Lock()
	defer k.mu.Unlock()

	proc, exists := k.processes[pid]
	if !exists {
		return fmt.Errorf("process not found in kernel: %s", pid)
	}

	var foundCp *Checkpoint
	for _, cp := range proc.Checkpoints {
		if cp.CheckpointID == checkpointID {
			foundCp = cp
			break
		}
	}
	if foundCp == nil {
		return fmt.Errorf("checkpoint %s not found for process %s", checkpointID, pid)
	}

	proc.State = ProcessReady
	logger.Info().Str("pid", pid).Str("checkpoint", checkpointID).Msg("Mission Kernel performed process rollback to checkpoint")

	k.emitEvent(context.Background(), EventProcessRollback, proc)
	return nil
}

// ForkProcess spawns a child process (e.g. alternative scaffold mission when parent stalls).
func (k *MissionKernel) ForkProcess(parentPID, newMissionID, reason string) (*MissionProcess, error) {
	k.mu.Lock()
	defer k.mu.Unlock()

	parent, exists := k.processes[parentPID]
	if !exists {
		return nil, fmt.Errorf("parent process not found: %s", parentPID)
	}

	childPID := fmt.Sprintf("pid_fork_%d", time.Now().UnixNano())
	child := &MissionProcess{
		PID:          childPID,
		ParentPID:    parentPID,
		MissionID:    newMissionID,
		Version:      parent.Version,
		State:        ProcessReady,
		Dependencies: []string{},
		Attempt:      1,
		MaxAttempts:  parent.MaxAttempts,
		Checkpoints:  make([]*Checkpoint, 0),
		ContextData:  map[string]any{"fork_reason": reason, "parent_mission": parent.MissionID},
	}

	// Parent blocks waiting for forked child to complete
	parent.State = ProcessBlocked
	parent.Dependencies = append(parent.Dependencies, childPID)

	k.processes[childPID] = child
	logger.Info().Str("parent_pid", parentPID).Str("child_pid", childPID).Str("reason", reason).Msg("Mission Kernel forked alternative learning process")

	k.emitEvent(context.Background(), EventProcessForked, child)
	return child, nil
}

// RecoverProcess handles process failure by either retrying or automatically forking a scaffold mission.
func (k *MissionKernel) RecoverProcess(pid string) (*MissionProcess, error) {
	k.mu.Lock()
	proc, exists := k.processes[pid]
	if !exists {
		k.mu.Unlock()
		return nil, fmt.Errorf("process not found: %s", pid)
	}

	if proc.Attempt < proc.MaxAttempts {
		proc.Attempt++
		proc.State = ProcessRecovering
		logger.Info().Str("pid", pid).Int("attempt", proc.Attempt).Msg("Mission Kernel retrying process execution")
		k.mu.Unlock()
		k.emitEvent(context.Background(), EventProcessRecovered, proc)
		return proc, nil
	}

	// Max attempts reached -> Unlock before calling ForkProcess to prevent deadlock!
	missionID := proc.MissionID
	k.mu.Unlock()

	logger.Info().Str("pid", pid).Msg("Max retry attempts exhausted -> Kernel initiating automatic Fork for scaffold mission")
	scaffoldMissionID := fmt.Sprintf("%s_scaffold_recovery", missionID)
	return k.ForkProcess(pid, scaffoldMissionID, "Max attempts exhausted; automatically branching to scaffolding drill")
}

func (k *MissionKernel) GetProcess(pid string) *MissionProcess {
	k.mu.RLock()
	defer k.mu.RUnlock()
	return k.processes[pid]
}

func (k *MissionKernel) emitEvent(ctx context.Context, eventType string, payload any) {
	if k.bus == nil {
		return
	}
	payloadBytes, _ := json.Marshal(payload)
	busEvent := kernel.Event{
		ID:        fmt.Sprintf("evt_krn_%d", time.Now().UnixNano()),
		Type:      eventType,
		Source:    "mission_kernel_process_controller",
		Timestamp: time.Now(),
		Payload:   payloadBytes,
	}
	_ = k.bus.Publish(ctx, busEvent)
}
