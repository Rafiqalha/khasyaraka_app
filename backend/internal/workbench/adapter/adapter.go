// Package adapter defines the Domain Adapter contract for the Cognitive Workbench.
// Domain Adapters are the boundary between domain-specific environments
// (Python, Cybersecurity, SQL, DevOps) and the Canonical Workbench Event Contract.
//
// The Core Platform and Mission Engine NEVER know which domain they are running.
// Domain Adapters translate domain-specific signals into Workbench vocabulary.
package adapter

import (
	"context"

	"github.com/pradigi/backend/internal/workbench/domain"
)

// CapabilityBinding resolves a declared capability to its concrete implementation.
// Mission says: "I need 'execution'".
// Adapter says: "For Python domain, 'execution' = DockerPythonExecutor."
type CapabilityBinding struct {
	Capability string // "code_editor", "terminal", "execution", "mentor"
	ToolID     string // Resolved implementation ID
	Config     map[string]any
}

// DomainAdapter is the universal contract for all domain adapters.
// Each domain (Python, Cyber, SQL) implements this.
type DomainAdapter interface {
	// DomainName returns the canonical domain identifier.
	DomainName() string // "python", "cybersecurity", "sql"

	// ResolveCapabilities translates Mission capability requirements
	// into concrete tool bindings for this domain.
	ResolveCapabilities(ctx context.Context, required []string) ([]CapabilityBinding, error)

	// TranslateEvent maps a domain-specific signal to a Workbench Event.
	// e.g., Python: "python.stdout" -> WBEventToolOutputGenerated
	TranslateEvent(ctx context.Context, domainSignal map[string]any) (domain.WorkbenchEventType, map[string]any, error)

	// BuildInitialEnvironment creates the starting state for a given Scenario.
	BuildInitialEnvironment(ctx context.Context, scenario domain.Scenario) ([]domain.EnvironmentSnapshot, error)
}
