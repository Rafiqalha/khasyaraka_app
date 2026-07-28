package mission_compiler

// MissionBundle is the final executable configuration that the Mission Runtime loads.
// It is strictly a declarative config.
type MissionBundle struct {
	WorkspaceConfig WorkspaceConfig        `json:"workspace"`
	PanelsConfig    []string               `json:"panels"`
	PluginsConfig   []string               `json:"plugins"`
	StateConfig     map[string]interface{} `json:"state"`
	Permissions     []string               `json:"permissions"`
}

type WorkspaceConfig struct {
	Title     string            `json:"title"`
	Objective string            `json:"objective"`
	Challenge string            `json:"challenge"`
	SeedFiles map[string]string `json:"seed_files"`
}

type InputPackage struct {
	Title             string            `json:"title"`
	Objective         string            `json:"objective"`
	Challenge         string            `json:"challenge"`
	RequiredPanels    []string          `json:"required_panels"`
	EvaluationRules   []string          `json:"evaluation_rules"`
	ReflectionPrompts []string          `json:"reflection_prompts"`
	SeedFiles         map[string]string `json:"seed_files"`
}

// Compiler takes the AI-generated package and translates it into a deterministic
// MissionBundle that the OS Kernel (Runtime) understands.
type Compiler struct{}

func NewCompiler() *Compiler {
	return &Compiler{}
}

// Compile takes the generated package and maps it to a strict bundle.
func (c *Compiler) Compile(pkg *InputPackage) (*MissionBundle, error) {
	bundle := &MissionBundle{
		WorkspaceConfig: WorkspaceConfig{
			Title:     pkg.Title,
			Objective: pkg.Objective,
			Challenge: pkg.Challenge,
			SeedFiles: pkg.SeedFiles,
		},
		PanelsConfig:  c.validatePanels(pkg.RequiredPanels),
		PluginsConfig: c.determinePlugins(pkg.RequiredPanels),
		StateConfig: map[string]interface{}{
			"evaluation_rules":   pkg.EvaluationRules,
			"reflection_prompts": pkg.ReflectionPrompts,
		},
		Permissions: []string{"read_workspace", "write_workspace"},
	}

	// In a real scenario, Sandbox needs execute permissions, Notebook might need internet.
	for _, plugin := range bundle.PluginsConfig {
		if plugin == "sandbox_service" {
			bundle.Permissions = append(bundle.Permissions, "execute_sandbox")
		}
	}

	return bundle, nil
}

// validatePanels ensures the AI didn't hallucinate non-existent panels.
func (c *Compiler) validatePanels(requested []string) []string {
	validPanels := map[string]bool{
		"editor":          true,
		"terminal":        true,
		"notebook":        true,
		"reflection":      true,
		"knowledge_graph": true,
		"browser":         true,
	}

	var approved []string
	for _, p := range requested {
		if validPanels[p] {
			approved = append(approved, p)
		}
	}
	// Fallback if AI hallucinates everything
	if len(approved) == 0 {
		approved = []string{"editor", "terminal"}
	}
	return approved
}

// determinePlugins determines which Headless Services need to be mounted based on the Panels requested.
func (c *Compiler) determinePlugins(panels []string) []string {
	plugins := make(map[string]bool)
	plugins["ai_service"] = true        // Director is always available
	plugins["knowledge_service"] = true // Always track capabilities

	for _, p := range panels {
		switch p {
		case "editor", "terminal", "browser":
			plugins["sandbox_service"] = true
			plugins["file_service"] = true
		case "notebook":
			plugins["notebook_service"] = true
		}
	}

	var result []string
	for k := range plugins {
		result = append(result, k)
	}
	return result
}
