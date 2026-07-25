package kernel

import (
	"fmt"
	"sync"
)

type defaultRegistry struct {
	plugins map[string]Plugin
	mu      sync.RWMutex
}

func NewRegistry() KernelRegistry {
	return &defaultRegistry{
		plugins: make(map[string]Plugin),
	}
}

func (r *defaultRegistry) Register(plugin Plugin) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	id := plugin.ID()
	if _, exists := r.plugins[id]; exists {
		return fmt.Errorf("plugin %s already registered", id)
	}

	r.plugins[id] = plugin
	return nil
}

func (r *defaultRegistry) Get(pluginID string) (Plugin, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	plugin, exists := r.plugins[pluginID]
	if !exists {
		return nil, fmt.Errorf("plugin %s not found", pluginID)
	}

	return plugin, nil
}
