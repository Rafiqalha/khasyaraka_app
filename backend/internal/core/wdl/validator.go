package wdl

import "fmt"

// ===========================
// Validator Pipeline
// Validates Workspace Definitions before mounting.
// ===========================

type Validator struct{}

func NewValidator() *Validator {
	return &Validator{}
}

func (v *Validator) Validate(manifest *WorkspaceManifest) error {
	if err := v.validateSchema(manifest); err != nil {
		return fmt.Errorf("schema validation failed: %w", err)
	}

	if err := v.validateSemantic(manifest); err != nil {
		return fmt.Errorf("semantic validation failed: %w", err)
	}

	if err := v.validateDependency(manifest); err != nil {
		return fmt.Errorf("dependency validation failed: %w", err)
	}

	return nil
}

func (v *Validator) validateSchema(m *WorkspaceManifest) error {
	if m.APIVersion != APIVersionV1Alpha1 {
		return fmt.Errorf("unsupported apiVersion: %s", m.APIVersion)
	}
	if m.Kind != KindWorkspaceDefinition {
		return fmt.Errorf("unsupported kind: %s", m.Kind)
	}
	if m.Metadata.ID == "" {
		return fmt.Errorf("metadata.id is required")
	}
	if m.Domain.Adapter == "" {
		return fmt.Errorf("domain.adapter is required")
	}
	return nil
}

func (v *Validator) validateSemantic(m *WorkspaceManifest) error {
	// e.g. check if docker image string is well-formed, etc.
	if m.Runtime.Driver == "docker" && m.Runtime.Image == "" {
		return fmt.Errorf("docker runtime requires an image")
	}
	return nil
}

func (v *Validator) validateDependency(m *WorkspaceManifest) error {
	// e.g. Check if requested tools are supported by the runtime capabilities.
	// In a real system, a "terminal" tool might require the "filesystem" and "network" capability
	// from the runtime. We simulate that here.
	
	runtimeCaps := make(map[string]bool)
	for _, cap := range m.Runtime.Capabilities {
		runtimeCaps[cap] = true
	}

	for _, tool := range m.Tools {
		if tool.Name == "terminal" && !runtimeCaps["filesystem"] {
			return fmt.Errorf("tool 'terminal' requires runtime capability 'filesystem'")
		}
	}
	return nil
}
