// Package python is the first Domain Adapter for the Cognitive Workbench.
// It maps the Python debugging domain to the canonical Workbench vocabulary.
//
// Structure:
//   domains/python/
//     adapter.go       — DomainAdapter implementation
//     mission/         — Mission definitions
//     environment/     — Initial environment builders
//     runtime/         — Python-specific runtime config (delegates to workbench/runtime)
//     evaluation/      — Python-specific evaluators
//     fixtures/        — Bug files and test suites (NOT hardcoded in Go)
//       tests/         — Corresponding test files
package python

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"github.com/pradigi/backend/internal/workbench/adapter"
	"github.com/pradigi/backend/internal/workbench/domain"
	wbruntime "github.com/pradigi/backend/internal/workbench/runtime"
)

// Adapter is the Python Domain Adapter.
// It resolves capability requirements to Python-specific tool bindings
// and translates Python signals to canonical Workbench Events.
type Adapter struct {
	fixturesDir string
	registry    *wbruntime.Registry
}

// Ensure Adapter implements adapter.DomainAdapter at compile time.
var _ adapter.DomainAdapter = (*Adapter)(nil)

func NewAdapter(fixturesDir string, registry *wbruntime.Registry) *Adapter {
	return &Adapter{
		fixturesDir: fixturesDir,
		registry:    registry,
	}
}

func (a *Adapter) DomainName() string { return "python" }

func (a *Adapter) ResolveCapabilities(ctx context.Context, required []string) ([]adapter.CapabilityBinding, error) {
	bindings := make([]adapter.CapabilityBinding, 0, len(required))

	for _, cap := range required {
		switch cap {
		case "code_editor":
			bindings = append(bindings, adapter.CapabilityBinding{
				Capability: "code_editor",
				ToolID:     "python_editor",
				Config:     map[string]any{"language": "python", "syntax_highlight": true},
			})
		case "terminal":
			bindings = append(bindings, adapter.CapabilityBinding{
				Capability: "terminal",
				ToolID:     "python_console",
				Config:     map[string]any{"shell": "bash"},
			})
		case "execution":
			rt := a.registry.Resolve("python")
			runtimeName := "unknown"
			if rt != nil {
				runtimeName = rt.Info().Name
			}
			bindings = append(bindings, adapter.CapabilityBinding{
				Capability: "execution",
				ToolID:     "python_executor",
				Config:     map[string]any{"runtime": runtimeName, "language": "python"},
			})
		case "mentor":
			bindings = append(bindings, adapter.CapabilityBinding{
				Capability: "mentor",
				ToolID:     "ai_mentor",
				Config:     map[string]any{"persona": "python_debugging_mentor"},
			})
		default:
			return nil, fmt.Errorf("python adapter: unknown capability %q", cap)
		}
	}

	return bindings, nil
}

func (a *Adapter) TranslateEvent(ctx context.Context, domainSignal map[string]any) (domain.WorkbenchEventType, map[string]any, error) {
	signalType, ok := domainSignal["type"].(string)
	if !ok {
		return "", nil, fmt.Errorf("python adapter: missing signal type")
	}

	switch signalType {
	case "python.run":
		return domain.WBEventToolRequested, domainSignal, nil
	case "python.stdout", "python.stderr":
		return domain.WBEventToolOutputGenerated, domainSignal, nil
	case "python.execution_complete":
		return domain.WBEventToolExecuted, domainSignal, nil
	case "python.file_save":
		return domain.WBEventEnvironmentChanged, domainSignal, nil
	case "python.test_pass":
		return domain.WBEventObjectiveCompleted, domainSignal, nil
	default:
		return domain.WBEventToolExecuted, domainSignal, nil
	}
}

func (a *Adapter) BuildInitialEnvironment(ctx context.Context, scenario domain.Scenario) ([]domain.EnvironmentSnapshot, error) {
	// For Python missions, the initial environment is built from fixtures.
	// Scenario.InitialStateJSON contains: {"fixture_id": "bug_001"}
	// We load the fixture file from the fixtures directory.
	return []domain.EnvironmentSnapshot{}, nil
}

// LoadFixture reads a fixture file and its corresponding test from disk.
func (a *Adapter) LoadFixture(fixtureID string) (sourceCode []byte, testCode []byte, err error) {
	sourcePath := filepath.Join(a.fixturesDir, fixtureID+".py")
	sourceCode, err = os.ReadFile(sourcePath)
	if err != nil {
		return nil, nil, fmt.Errorf("fixture %q not found: %w", fixtureID, err)
	}

	testPath := filepath.Join(a.fixturesDir, "tests", fixtureID+"_test.py")
	testCode, _ = os.ReadFile(testPath) // Test is optional

	return sourceCode, testCode, nil
}
