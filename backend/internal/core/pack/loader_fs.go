package pack

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// FilesystemLoader implements Loader by reading YAML files from a local directory.
type FilesystemLoader struct{}

func NewFilesystemLoader() *FilesystemLoader {
	return &FilesystemLoader{}
}

func (l *FilesystemLoader) Load(ctx context.Context, descriptor *PackDescriptor) (*Pack, error) {
	baseDir := descriptor.BlueprintURI

	pack := &Pack{
		Descriptor:     *descriptor,
		ReferencesPath: filepath.Join(baseDir, "references"),
	}

	// Helper to unmarshal a specific YAML file into a target struct
	loadYaml := func(filename string, target interface{}) error {
		path := filepath.Join(baseDir, filename)
		data, err := os.ReadFile(path)
		if err != nil {
			if os.IsNotExist(err) {
				return nil // File is optional for now, except manifest
			}
			return fmt.Errorf("failed to read %s: %w", filename, err)
		}
		if err := yaml.Unmarshal(data, target); err != nil {
			return fmt.Errorf("failed to parse %s: %w", filename, err)
		}
		return nil
	}

	// 1. Load Manifest
	var manifest struct {
		Title       string `yaml:"title"`
		Description string `yaml:"description"`
	}
	if err := loadYaml("manifest.yaml", &manifest); err != nil {
		return nil, err
	}
	pack.Title = manifest.Title
	pack.Description = manifest.Description

	// 2. Load Capabilities
	var caps struct {
		Capabilities []Capability `yaml:"capabilities"`
	}
	if err := loadYaml("capabilities.yaml", &caps); err != nil {
		return nil, err
	}
	pack.Capabilities = caps.Capabilities

	// 3. Load Workspace
	var ws struct {
		Workspace WorkspaceConfig `yaml:"workspace"`
		Panels    []string        `yaml:"panels"`
		Tools     []ToolConfig    `yaml:"tools"`
	}
	if err := loadYaml("workspace.yaml", &ws); err != nil {
		return nil, err
	}
	pack.Workspace = ws.Workspace
	if len(ws.Tools) > 0 {
		pack.Workspace.Tools = ws.Tools
	}
	if len(pack.Workspace.Required) == 0 && len(ws.Panels) > 0 {
		pack.Workspace.Required = ws.Panels
	}

	// 4. Load Assessment
	var assessment struct {
		Evaluation AssessmentPolicy `yaml:"evaluation"`
	}
	if err := loadYaml("assessment.yaml", &assessment); err != nil {
		return nil, err
	}
	pack.Assessment = assessment.Evaluation

	// 5. Load Capability Policy
	if err := loadYaml("capability_policy.yaml", &pack.CapabilityPolicy); err != nil {
		return nil, err
	}

	// 6. Load Knowledge
	if err := loadYaml("knowledge.yaml", &pack.Knowledge); err != nil {
		return nil, err
	}

	// 7. Load Missions
	var missionsData struct {
		Missions []MissionBlueprint `yaml:"missions"`
	}
	if err := loadYaml("missions.yaml", &missionsData); err != nil {
		return nil, err
	}
	pack.Missions = missionsData.Missions

	// 8. Load AI Rules
	if err := loadYaml("ai_rules.yaml", &pack.AIRules); err != nil {
		return nil, err
	}

	return pack, nil
}
