package catalog

import (
	"fmt"
	"os"
	"path/filepath"
	"sync"

	"gopkg.in/yaml.v3"
)

// BlueprintRegistry - Thread-safe in-memory cache of all filesystem Blueprints.
type BlueprintRegistry struct {
	mu              sync.RWMutex
	baseDir         string
	academies       map[string]*AcademyBlueprint
	specializations map[string]*SpecializationBlueprint
	experiences     map[string]*ExperienceBlueprint
	packs           map[string]*PackBlueprint
}

func NewBlueprintRegistry(baseDir string) *BlueprintRegistry {
	return &BlueprintRegistry{
		baseDir:         baseDir,
		academies:       make(map[string]*AcademyBlueprint),
		specializations: make(map[string]*SpecializationBlueprint),
		experiences:     make(map[string]*ExperienceBlueprint),
		packs:           make(map[string]*PackBlueprint),
	}
}

// Load recursively scans the academies/ directory and populates all 5 levels of Blueprints.
func (r *BlueprintRegistry) Load() error {
	r.mu.Lock()
	defer r.mu.Unlock()

	dirPath := r.baseDir
	if _, err := os.Stat(filepath.Join(dirPath, "ai_academy")); os.IsNotExist(err) {
		fallback := filepath.Join("..", r.baseDir)
		if _, err := os.Stat(filepath.Join(fallback, "ai_academy")); err == nil {
			dirPath = fallback
		} else if _, err := os.Stat(dirPath); os.IsNotExist(err) {
			return fmt.Errorf("blueprint registry directory does not exist: %s", r.baseDir)
		}
	}

	entries, err := os.ReadDir(dirPath)
	if err != nil {
		return fmt.Errorf("failed to read blueprint directory: %w", err)
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		acadDir := filepath.Join(dirPath, entry.Name())
		acadMetaPath := filepath.Join(acadDir, "academy.yaml")
		if _, err := os.Stat(acadMetaPath); os.IsNotExist(err) {
			continue
		}

		data, err := os.ReadFile(acadMetaPath)
		if err != nil {
			return fmt.Errorf("failed to read academy meta at %s: %w", acadMetaPath, err)
		}

		var acad AcademyBlueprint
		if err := yaml.Unmarshal(data, &acad); err != nil {
			return fmt.Errorf("failed to unmarshal academy at %s: %w", acadMetaPath, err)
		}
		if acad.ID == "" {
			acad.ID = entry.Name()
		}
		acad.Path = acadDir
		r.academies[acad.ID] = &acad

		// Scan Specializations: academies/<acad>/specializations/
		specsDir := filepath.Join(acadDir, "specializations")
		specEntries, err := os.ReadDir(specsDir)
		if err != nil {
			continue
		}

		for _, specEntry := range specEntries {
			if !specEntry.IsDir() {
				continue
			}

			specDir := filepath.Join(specsDir, specEntry.Name())
			specMetaPath := filepath.Join(specDir, "specialization.yaml")
			if _, err := os.Stat(specMetaPath); os.IsNotExist(err) {
				continue
			}

			specData, err := os.ReadFile(specMetaPath)
			if err != nil {
				return fmt.Errorf("failed to read spec meta at %s: %w", specMetaPath, err)
			}

			var spec SpecializationBlueprint
			if err := yaml.Unmarshal(specData, &spec); err != nil {
				return fmt.Errorf("failed to unmarshal spec at %s: %w", specMetaPath, err)
			}
			if spec.ID == "" {
				spec.ID = specEntry.Name()
			}
			spec.AcademyID = acad.ID
			spec.Path = specDir
			r.specializations[spec.ID] = &spec

			// Scan Experiences: academies/<acad>/specializations/<spec>/experiences/
			expDir := filepath.Join(specDir, "experiences")
			if expEntries, err := os.ReadDir(expDir); err == nil {
				for _, expEntry := range expEntries {
					if !expEntry.IsDir() {
						continue
					}
					expPath := filepath.Join(expDir, expEntry.Name())
					expMetaPath := filepath.Join(expPath, "experience.yaml")
					if _, err := os.Stat(expMetaPath); os.IsNotExist(err) {
						continue
					}

					expData, err := os.ReadFile(expMetaPath)
					if err != nil {
						continue
					}

					var exp ExperienceBlueprint
					if err := yaml.Unmarshal(expData, &exp); err == nil {
						if exp.ID == "" {
							exp.ID = expEntry.Name()
						}
						exp.SpecializationID = spec.ID
						exp.Path = expPath
						hash, _ := ComputeDirSHA256(expPath)
						exp.ContentHash = hash
						r.experiences[exp.ID] = &exp
					}
				}
			}

			// Scan Packs: academies/<acad>/specializations/<spec>/packs/
			packsDir := filepath.Join(specDir, "packs")
			packEntries, err := os.ReadDir(packsDir)
			if err != nil {
				continue
			}

			for _, packEntry := range packEntries {
				packPath := filepath.Join(packsDir, packEntry.Name())
				manifestPath := filepath.Join(packPath, "manifest.yaml")
				if _, err := os.Stat(manifestPath); os.IsNotExist(err) {
					continue
				}

				packData, err := os.ReadFile(manifestPath)
				if err != nil {
					continue
				}

				var pack PackBlueprint
				if err := yaml.Unmarshal(packData, &pack); err != nil {
					continue
				}

				if pack.ID == "" {
					pack.ID = packEntry.Name()
				}
				pack.Path = packPath

				// Load Knowledge Blueprint if exists
				knowPath := filepath.Join(packPath, "knowledge.yaml")
				if knowData, err := os.ReadFile(knowPath); err == nil {
					var know KnowledgeBlueprint
					if err := yaml.Unmarshal(knowData, &know); err == nil {
						pack.Knowledge = &know
					}
				}

				// Load Workspace Blueprint if exists
				wsPath := filepath.Join(packPath, "workspace.yaml")
				if wsData, err := os.ReadFile(wsPath); err == nil {
					var ws WorkspaceBlueprint
					if err := yaml.Unmarshal(wsData, &ws); err == nil {
						pack.Workspace = &ws
					}
				}

				// Load Mission Blueprints from missions/ directory
				missionsDir := filepath.Join(packPath, "missions")
				if mEntries, err := os.ReadDir(missionsDir); err == nil {
					for _, mEntry := range mEntries {
						if mEntry.IsDir() || filepath.Ext(mEntry.Name()) != ".yaml" {
							continue
						}
						mData, err := os.ReadFile(filepath.Join(missionsDir, mEntry.Name()))
						if err != nil {
							continue
						}
						var m MissionBlueprint
						if err := yaml.Unmarshal(mData, &m); err == nil {
							pack.Missions = append(pack.Missions, &m)
						}
					}
				}

				// Calculate Content Hash for Pack
				hash, _ := ComputeDirSHA256(packPath)
				pack.ContentHash = hash
				r.packs[pack.ID] = &pack
			}
		}
	}

	return nil
}

func (r *BlueprintRegistry) GetAcademies() []*AcademyBlueprint {
	r.mu.RLock()
	defer r.mu.RUnlock()

	result := make([]*AcademyBlueprint, 0, len(r.academies))
	for _, a := range r.academies {
		result = append(result, a)
	}
	return result
}

func (r *BlueprintRegistry) GetSpecializations(academyID string) []*SpecializationBlueprint {
	r.mu.RLock()
	defer r.mu.RUnlock()

	result := make([]*SpecializationBlueprint, 0)
	for _, s := range r.specializations {
		if academyID == "" || s.AcademyID == academyID {
			result = append(result, s)
		}
	}
	return result
}

func (r *BlueprintRegistry) GetExperience(experienceID string) (*ExperienceBlueprint, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	exp, ok := r.experiences[experienceID]
	return exp, ok
}

func (r *BlueprintRegistry) GetPack(packID string) (*PackBlueprint, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	pack, ok := r.packs[packID]
	return pack, ok
}
