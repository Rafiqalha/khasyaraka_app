package wdl

import (
	"log"
	"os"
	"path/filepath"
)

// ===========================
// Workspace Provisioner
// Scans the filesystem for WDL files and mounts them into the Registry.
// ===========================

type Provisioner struct {
	parser    *Parser
	validator *Validator
	registry  WorkspaceRegistry
}

func NewProvisioner(registry WorkspaceRegistry) *Provisioner {
	return &Provisioner{
		parser:    NewParser(),
		validator: NewValidator(),
		registry:  registry,
	}
}

// ProvisionAll scans the root path (e.g. "academies/") and registers all found Workspaces.
func (p *Provisioner) ProvisionAll(rootPath string) error {
	return filepath.Walk(rootPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !info.IsDir() && info.Name() == "workspace.yaml" {
			log.Printf("Found WDL manifest: %s", path)

			manifest, err := p.parser.ParseFile(path)
			if err != nil {
				log.Printf("Failed to parse %s: %v", path, err)
				return nil // Skip on error, don't crash the whole provisioner
			}

			if err := p.validator.Validate(manifest); err != nil {
				log.Printf("Validation failed for %s: %v", manifest.Metadata.ID, err)
				return nil // Skip on error
			}

			if err := p.registry.Register(manifest); err != nil {
				log.Printf("Failed to register %s: %v", manifest.Metadata.ID, err)
				return nil
			}

			log.Printf("Successfully mounted Workspace: %s (%s)", manifest.Metadata.Name, manifest.Metadata.ID)
		}

		return nil
	})
}
