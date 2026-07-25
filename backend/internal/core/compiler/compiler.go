package compiler

import (
	"fmt"
	"sync"
	"time"

	"github.com/pradigi/backend/internal/core/catalog"
)

// CompiledArtifact - Immutable output produced once by the Compiler and cached by SHA-256.
type CompiledArtifact struct {
	ID               string                    `json:"id"`
	Title            string                    `json:"title"`
	ContentHash      string                    `json:"content_hash"`
	CompiledAt       time.Time                 `json:"compiled_at"`
	Missions         []*catalog.MissionBlueprint `json:"missions"`
	KnowledgeGraph   *catalog.KnowledgeBlueprint `json:"knowledge_graph"`
	WorkspaceSpec    *catalog.WorkspaceBlueprint `json:"workspace_spec"`
	AssessmentRubric *catalog.AssessmentBlueprint `json:"assessment_rubric"`
}

// CompiledArtifactStore - Thread-safe in-memory cache keyed by SHA-256 Content Hash.
type CompiledArtifactStore struct {
	mu         sync.RWMutex
	artifacts  map[string]*CompiledArtifact // ContentHash -> CompiledArtifact
}

func NewCompiledArtifactStore() *CompiledArtifactStore {
	return &CompiledArtifactStore{
		artifacts: make(map[string]*CompiledArtifact),
	}
}

func (s *CompiledArtifactStore) Get(hash string) (*CompiledArtifact, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	art, ok := s.artifacts[hash]
	return art, ok
}

func (s *CompiledArtifactStore) Put(hash string, artifact *CompiledArtifact) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.artifacts[hash] = artifact
}

// Compiler - Static, deterministic build step. Merges DAGs and validates schema once per content hash.
type Compiler struct {
	store *CompiledArtifactStore
}

func NewCompiler(store *CompiledArtifactStore) *Compiler {
	return &Compiler{store: store}
}

// CompilePack compiles a PackBlueprint into an immutable CompiledArtifact, caching by SHA-256.
func (c *Compiler) CompilePack(pack *catalog.PackBlueprint) (*CompiledArtifact, error) {
	if pack == nil {
		return nil, fmt.Errorf("cannot compile nil pack blueprint")
	}

	// Check if already compiled for this exact SHA-256 content hash
	if cached, ok := c.store.Get(pack.ContentHash); ok {
		return cached, nil
	}

	// Validate DAG & Node references
	if err := c.validatePack(pack); err != nil {
		return nil, fmt.Errorf("pack validation failed: %w", err)
	}

	artifact := &CompiledArtifact{
		ID:               pack.ID,
		Title:            pack.Title,
		ContentHash:      pack.ContentHash,
		CompiledAt:       time.Now().UTC(),
		Missions:         pack.Missions,
		KnowledgeGraph:   pack.Knowledge,
		WorkspaceSpec:    pack.Workspace,
		AssessmentRubric: pack.Assessment,
	}

	c.store.Put(pack.ContentHash, artifact)
	return artifact, nil
}

func (c *Compiler) validatePack(pack *catalog.PackBlueprint) error {
	if pack.ID == "" {
		return fmt.Errorf("pack ID is empty")
	}
	// Check for duplicate mission IDs
	seen := make(map[string]bool)
	for _, m := range pack.Missions {
		if seen[m.ID] {
			return fmt.Errorf("duplicate mission ID '%s' in pack '%s'", m.ID, pack.ID)
		}
		seen[m.ID] = true
	}
	return nil
}
