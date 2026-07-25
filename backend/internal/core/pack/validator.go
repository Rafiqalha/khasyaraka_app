package pack

import (
	"fmt"
)

// ValidatePack performs graph integrity & structure checks on a loaded Pack blueprint.
// Server fail-fast if circular or missing mission/capability dependencies are detected.
func ValidatePack(p *Pack) error {
	if p.Title == "" {
		return fmt.Errorf("pack title cannot be empty (Pack ID: %s)", p.Descriptor.ID)
	}

	missionIDs := make(map[string]bool)
	for _, m := range p.Missions {
		if m.ID == "" {
			return fmt.Errorf("found mission with empty ID in pack %s", p.Descriptor.ID)
		}
		if missionIDs[m.ID] {
			return fmt.Errorf("duplicate mission ID '%s' found in pack %s", m.ID, p.Descriptor.ID)
		}
		missionIDs[m.ID] = true
	}

	// Validate mission dependency references
	for _, m := range p.Missions {
		for _, dep := range m.Dependencies {
			if !missionIDs[dep] {
				return fmt.Errorf("mission '%s' in pack '%s' depends on unknown mission '%s'", m.ID, p.Descriptor.ID, dep)
			}
		}
	}

	// Validate capabilities graph
	capIDs := make(map[string]bool)
	for _, c := range p.Capabilities {
		if c.ID != "" {
			capIDs[c.ID] = true
		}
	}
	for _, c := range p.Capabilities {
		for _, dep := range c.Dependencies {
			if !capIDs[dep] {
				return fmt.Errorf("capability '%s' in pack '%s' depends on unknown capability '%s'", c.ID, p.Descriptor.ID, dep)
			}
		}
	}

	return nil
}
