package wdl

import "sync"

// ===========================
// Workspace Registry
// The central hub where Workbench and Adaptive Engine query available Workspaces.
// ===========================

type WorkspaceRegistry interface {
	Register(manifest *WorkspaceManifest) error
	Get(id string) (*WorkspaceManifest, bool)
	ListAll() []*WorkspaceManifest
	
	// Capability Negotiation: Adaptive Engine asks "Who can serve this blueprint?"
	FindCapableWorkspaces(requiredTools []string, requiredAgents []string) []*WorkspaceManifest
}

type InMemoryWorkspaceRegistry struct {
	mu         sync.RWMutex
	workspaces map[string]*WorkspaceManifest
}

func NewWorkspaceRegistry() WorkspaceRegistry {
	return &InMemoryWorkspaceRegistry{
		workspaces: make(map[string]*WorkspaceManifest),
	}
}

func (r *InMemoryWorkspaceRegistry) Register(manifest *WorkspaceManifest) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.workspaces[manifest.Metadata.ID] = manifest
	return nil
}

func (r *InMemoryWorkspaceRegistry) Get(id string) (*WorkspaceManifest, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	m, ok := r.workspaces[id]
	return m, ok
}

func (r *InMemoryWorkspaceRegistry) ListAll() []*WorkspaceManifest {
	r.mu.RLock()
	defer r.mu.RUnlock()
	
	var list []*WorkspaceManifest
	for _, m := range r.workspaces {
		list = append(list, m)
	}
	return list
}

func (r *InMemoryWorkspaceRegistry) FindCapableWorkspaces(requiredTools []string, requiredAgents []string) []*WorkspaceManifest {
	r.mu.RLock()
	defer r.mu.RUnlock()
	
	var capable []*WorkspaceManifest
	
	for _, m := range r.workspaces {
		// Check tools
		toolMap := make(map[string]bool)
		for _, t := range m.Tools {
			toolMap[t.Name] = true
		}
		
		hasTools := true
		for _, req := range requiredTools {
			if !toolMap[req] {
				hasTools = false
				break
			}
		}
		if !hasTools {
			continue
		}

		// Check agents
		agentMap := make(map[string]bool)
		for _, a := range m.Agents {
			agentMap[a.Role] = true
		}
		
		hasAgents := true
		for _, req := range requiredAgents {
			if !agentMap[req] {
				hasAgents = false
				break
			}
		}
		if !hasAgents {
			continue
		}

		capable = append(capable, m)
	}
	
	return capable
}
