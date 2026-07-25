package compiler

import (
	"context"
	"testing"
	"time"

	"github.com/pradigi/backend/internal/core/telemetry"
)

func TestAdaptiveCompilerFastPath(t *testing.T) {
	bank := NewRevisionBank()
	analyzer := telemetry.NewTelemetryAnalyzer()
	compiler := NewAdaptiveCurriculumCompiler(bank, analyzer, nil)

	input := telemetry.TelemetryInput{
		ConceptID:     "python.array",
		Stderr:        "IndexError: list index out of range",
		EditCount:     15,
		ExecutionTime: 2 * time.Minute,
		FailCount:     2,
	}

	start := time.Now()
	rev, err := compiler.CompileAdaptiveRevision(context.Background(), "python.array", input, 1)
	duration := time.Since(start)

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if rev == nil {
		t.Fatalf("expected non-nil revision")
	}

	if rev.Pedagogy != "visual" {
		t.Errorf("expected pedagogy 'visual' for IndexError, got '%s'", rev.Pedagogy)
	}

	if duration > 5*time.Millisecond {
		t.Errorf("expected fast path execution < 5ms, took %v", duration)
	}
}
