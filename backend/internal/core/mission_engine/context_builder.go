package mission_engine

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"github.com/pradigi/backend/internal/core/pack"
	"github.com/pradigi/backend/internal/core/planner"
)

// MissionContext is the fully assembled knowledge context that the Mission Engine
// uses to generate a mission without hallucinating.
type MissionContext struct {
	Plan              *planner.MissionPlan
	AIRules           *pack.AIRulesConfig
	ReferenceConcepts string
	ReferenceExamples string
	ReferenceRubrics  string
}

// ContextBuilder is responsible for gathering RAG resources (like references, anti_patterns)
// from the Pack's file system or database, strictly scoping the AI's generation.
type ContextBuilder interface {
	BuildContext(ctx context.Context, plan *planner.MissionPlan, referencesPath string) (*MissionContext, error)
}

type DefaultContextBuilder struct{}

func NewDefaultContextBuilder() *DefaultContextBuilder {
	return &DefaultContextBuilder{}
}

func (b *DefaultContextBuilder) BuildContext(ctx context.Context, plan *planner.MissionPlan, referencesPath string) (*MissionContext, error) {
	// Simple RAG logic: read from the references/ directory
	mctx := &MissionContext{
		Plan: plan,
	}

	// Helper to safely read a directory of references
	readDirFiles := func(subDir string) string {
		path := filepath.Join(referencesPath, subDir)
		entries, err := os.ReadDir(path)
		if err != nil {
			return "" // Ignore if folder missing
		}

		var content string
		for _, e := range entries {
			if !e.IsDir() {
				data, _ := os.ReadFile(filepath.Join(path, e.Name()))
				content += string(data) + "\n\n"
			}
		}
		return content
	}

	mctx.ReferenceConcepts = readDirFiles("concepts")
	mctx.ReferenceExamples = readDirFiles("examples")
	mctx.ReferenceRubrics = readDirFiles("rubrics")

	// If no concepts were found, just provide a fallback (or an error depending on strictness)
	if mctx.ReferenceConcepts == "" {
		mctx.ReferenceConcepts = fmt.Sprintf("Target Capability: %s", plan.TargetCapability.Name)
	}

	return mctx, nil
}
