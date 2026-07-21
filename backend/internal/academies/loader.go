package academies

import (
	"fmt"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// Loader handles the Hybrid Loading strategy for Academies.
type Loader struct {
	env string
}

func NewLoader(env string) *Loader {
	return &Loader{env: env}
}

// Load loads all academies in a directory depending on the environment.
func (l *Loader) Load(basePath string) ([]Bundle, error) {
	if l.env == "development" {
		return l.loadFromYAML(basePath)
	}
	return l.loadFromCompiled(basePath)
}

func (l *Loader) loadFromYAML(basePath string) ([]Bundle, error) {
	var bundles []Bundle

	// In dev mode, we read raw directories
	entries, err := os.ReadDir(basePath)
	if err != nil {
		if os.IsNotExist(err) {
			return bundles, nil
		}
		return nil, err
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		academyDir := filepath.Join(basePath, entry.Name())
		manifestPath := filepath.Join(academyDir, "academy.yaml")

		data, err := os.ReadFile(manifestPath)
		if err != nil {
			fmt.Printf("Skipping %s: no academy.yaml found\n", entry.Name())
			continue
		}

		var manifest AcademyManifest
		if err := yaml.Unmarshal(data, &manifest); err != nil {
			return nil, fmt.Errorf("failed to parse %s: %w", manifestPath, err)
		}

		bundles = append(bundles, Bundle{
			Manifest:       manifest,
			CurriculumPath: filepath.Join(academyDir, "curriculum"),
			KnowledgePath:  filepath.Join(academyDir, "knowledge"),
			WorkspacePath:  filepath.Join(academyDir, "workspace"),
			IsCompiled:     false,
		})
	}

	return bundles, nil
}

func (l *Loader) loadFromCompiled(basePath string) ([]Bundle, error) {
	// In production, we would load from pre-compiled .pack files in the DB or filesystem.
	// For now, return empty or implement a mock bundle loader.
	return []Bundle{}, nil
}
