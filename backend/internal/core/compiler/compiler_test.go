package compiler

import (
	"testing"

	"github.com/pradigi/backend/internal/core/catalog"
)

func TestCompilerSHA256Caching(t *testing.T) {
	store := NewCompiledArtifactStore()
	comp := NewCompiler(store)

	pack := &catalog.PackBlueprint{
		ID:          "test_pack",
		Title:       "Test Pack",
		ContentHash: "a1b2c3d4e5f67890abcdef1234567890a1b2c3d4e5f67890abcdef1234567890",
		Missions: []*catalog.MissionBlueprint{
			{ID: "m1", Title: "Mission 1"},
		},
	}

	artifact1, err := comp.CompilePack(pack)
	if err != nil {
		t.Fatalf("unexpected compilation error: %v", err)
	}

	if artifact1.ContentHash != pack.ContentHash {
		t.Errorf("expected hash %s, got %s", pack.ContentHash, artifact1.ContentHash)
	}

	// Compile second time with same ContentHash — must return identical cached instance
	artifact2, err := comp.CompilePack(pack)
	if err != nil {
		t.Fatalf("unexpected compilation error on 2nd compile: %v", err)
	}

	if artifact1 != artifact2 {
		t.Errorf("expected cached artifact instance pointer to match")
	}
}
