package runtime

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// runtimeCtx implements kernel.RuntimeContext
type runtimeCtx struct {
	sessionID string
	state     kernel.MissionState
	runtime   *MissionRuntimeImpl
}

func (c *runtimeCtx) SessionID() string {
	return c.sessionID
}

func (c *runtimeCtx) State() kernel.MissionState {
	return c.state
}

func (c *runtimeCtx) Snapshot() kernel.RuntimeSnapshot {
	// In reality, this would fetch from Redis or Database
	return kernel.RuntimeSnapshot{
		SessionID:          c.sessionID,
		ProgressPercentage: 0.0,
	}
}

func (c *runtimeCtx) Emit(ctx context.Context, eventType string, payload interface{}) error {
	return c.runtime.Emit(ctx, eventType, payload)
}

// MissionRuntimeImpl implements kernel.MissionRuntime
type MissionRuntimeImpl struct {
	sessionID string
	state     kernel.MissionState
	bus       kernel.EventBus
	registry  kernel.KernelRegistry

	activePlugins map[string]kernel.Plugin
	mu            sync.RWMutex
}

func NewMissionRuntime(sessionID string, bus kernel.EventBus, registry kernel.KernelRegistry) *MissionRuntimeImpl {
	return &MissionRuntimeImpl{
		sessionID:     sessionID,
		state:         kernel.StateProvisioning,
		bus:           bus,
		registry:      registry,
		activePlugins: make(map[string]kernel.Plugin),
	}
}

func (r *MissionRuntimeImpl) Context() kernel.RuntimeContext {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return &runtimeCtx{
		sessionID: r.sessionID,
		state:     r.state,
		runtime:   r,
	}
}

func (r *MissionRuntimeImpl) Start(ctx context.Context) error {
	return r.TransitionState(ctx, kernel.StateBriefing)
}

func (r *MissionRuntimeImpl) Pause(ctx context.Context) error {
	return r.TransitionState(ctx, kernel.StatePaused)
}

func (r *MissionRuntimeImpl) Stop(ctx context.Context) error {
	return r.TransitionState(ctx, kernel.StateCompleted)
}

func (r *MissionRuntimeImpl) CurrentState() kernel.MissionState {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return r.state
}

func (r *MissionRuntimeImpl) TransitionState(ctx context.Context, newState kernel.MissionState) error {
	r.mu.Lock()
	oldState := r.state
	r.state = newState
	r.mu.Unlock()

	logger.Info().Str("session", r.sessionID).Str("from", string(oldState)).Str("to", string(newState)).Msg("Mission State Transition")

	payload, _ := json.Marshal(map[string]string{
		"old_state": string(oldState),
		"new_state": string(newState),
	})

	return r.Emit(ctx, "STATE_TRANSITION", payload)
}

func (r *MissionRuntimeImpl) Mount(ctx context.Context, pluginID string) error {
	plugin, err := r.registry.Get(pluginID)
	if err != nil {
		return fmt.Errorf("failed to mount plugin %s: %w", pluginID, err)
	}

	r.mu.Lock()
	defer r.mu.Unlock()

	if _, exists := r.activePlugins[pluginID]; exists {
		return nil // Already mounted
	}

	if err := plugin.Initialize(r.Context()); err != nil {
		return fmt.Errorf("failed to initialize plugin %s: %w", pluginID, err)
	}

	r.activePlugins[pluginID] = plugin
	logger.Info().Str("plugin", pluginID).Msg("Plugin mounted to Mission Runtime")
	return nil
}

func (r *MissionRuntimeImpl) Unmount(ctx context.Context, pluginID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	plugin, exists := r.activePlugins[pluginID]
	if !exists {
		return nil
	}

	if err := plugin.Shutdown(r.Context()); err != nil {
		logger.Error().Err(err).Str("plugin", pluginID).Msg("Failed to cleanly shutdown plugin")
	}

	delete(r.activePlugins, pluginID)
	logger.Info().Str("plugin", pluginID).Msg("Plugin unmounted from Mission Runtime")
	return nil
}

func (r *MissionRuntimeImpl) Emit(ctx context.Context, eventType string, payload interface{}) error {
	payloadBytes, _ := json.Marshal(payload)
	event := kernel.Event{
		ID:        fmt.Sprintf("evt_%d", time.Now().UnixNano()),
		Type:      eventType,
		Source:    "mission_runtime",
		Timestamp: time.Now(),
		Payload:   payloadBytes,
	}
	return r.bus.Publish(ctx, event)
}

// LoadBundle provisions the runtime based on the compiled MissionBundle
func (r *MissionRuntimeImpl) LoadBundle(ctx context.Context, bundle *mission_compiler.MissionBundle) error {
	// Mount requested plugins
	for _, pluginID := range bundle.PluginsConfig {
		if err := r.Mount(ctx, pluginID); err != nil {
			return err
		}
	}
	return nil
}
