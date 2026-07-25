package catalog

import (
	"fmt"
	"os"
	"path/filepath"
	"sync"

	"gopkg.in/yaml.v3"
)

type AcademyMeta struct {
	ID          string `yaml:"id" json:"id"`
	Title       string `yaml:"title" json:"title"`
	Icon        string `yaml:"icon" json:"icon"`
	Color       string `yaml:"color" json:"color"`
	Description string `yaml:"description" json:"description"`
	Order       int    `yaml:"order" json:"order"`
}

type SpecializationMeta struct {
	ID          string   `yaml:"id" json:"id"`
	Title       string   `yaml:"title" json:"title"`
	AcademyID   string   `yaml:"academy_id" json:"academy_id"`
	Description string   `yaml:"description" json:"description"`
	Prerequisites []string `yaml:"prerequisites" json:"prerequisites"`
	Order       int      `yaml:"order" json:"order"`
}

type ContentRegistry struct {
	mu              sync.RWMutex
	baseDir         string
	academies       map[string]*AcademyMeta
	specializations map[string]*SpecializationMeta
	packPaths       map[string]string // PackID -> PackBlueprint path
}

func NewContentRegistry(baseDir string) *ContentRegistry {
	return &ContentRegistry{
		baseDir:         baseDir,
		academies:       make(map[string]*AcademyMeta),
		specializations: make(map[string]*SpecializationMeta),
		packPaths:       make(map[string]string),
	}
}

// Load scans the filesystem and loads all Academy, Specialization, and Pack manifests into memory
func (r *ContentRegistry) Load() error {
	r.mu.Lock()
	defer r.mu.Unlock()

	if _, err := os.Stat(filepath.Join(r.baseDir, "ai_academy")); os.IsNotExist(err) {
		fallback := filepath.Join("..", r.baseDir)
		if _, err := os.Stat(filepath.Join(fallback, "ai_academy")); err == nil {
			r.baseDir = fallback
		} else if _, err := os.Stat(r.baseDir); os.IsNotExist(err) {
			return fmt.Errorf("content registry base dir does not exist: %s", r.baseDir)
		}
	}

	entries, err := os.ReadDir(r.baseDir)
	if err != nil {
		return fmt.Errorf("failed to read content base dir: %w", err)
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		acadDir := filepath.Join(r.baseDir, entry.Name())
		acadMetaPath := filepath.Join(acadDir, "academy.yaml")
		if _, err := os.Stat(acadMetaPath); os.IsNotExist(err) {
			continue
		}

		data, err := os.ReadFile(acadMetaPath)
		if err != nil {
			return fmt.Errorf("failed to read academy meta at %s: %w", acadMetaPath, err)
		}

		var meta AcademyMeta
		if err := yaml.Unmarshal(data, &meta); err != nil {
			return fmt.Errorf("failed to unmarshal academy meta at %s: %w", acadMetaPath, err)
		}
		if meta.ID == "" {
			meta.ID = entry.Name()
		}
		r.academies[meta.ID] = &meta

		// Load Specializations under academies/<academy>/specializations/
		specsDir := filepath.Join(acadDir, "specializations")
		if specEntries, err := os.ReadDir(specsDir); err == nil {
			for _, specEntry := range specEntries {
				if !specEntry.IsDir() {
					continue
				}

				specDir := filepath.Join(specsDir, specEntry.Name())
				specMetaPath := filepath.Join(specDir, "specialization.yaml")
				if _, err := os.Stat(specMetaPath); err != nil {
					continue
				}

				specData, err := os.ReadFile(specMetaPath)
				if err != nil {
					return fmt.Errorf("failed to read specialization meta at %s: %w", specMetaPath, err)
				}

				var specMeta SpecializationMeta
				if err := yaml.Unmarshal(specData, &specMeta); err != nil {
					return fmt.Errorf("failed to unmarshal specialization meta at %s: %w", specMetaPath, err)
				}
				if specMeta.ID == "" {
					specMeta.ID = specEntry.Name()
				}
				specMeta.AcademyID = meta.ID
				r.specializations[specMeta.ID] = &specMeta

				// Discover Packs under academies/<academy>/specializations/<spec>/packs/
				packsDir := filepath.Join(specDir, "packs")
				if packEntries, err := os.ReadDir(packsDir); err == nil {
					for _, packEntry := range packEntries {
						packPath := filepath.Join(packsDir, packEntry.Name())
						r.packPaths[packEntry.Name()] = packPath
					}
				}
			}
		}
	}

	return nil
}

func (r *ContentRegistry) GetAcademies() []*AcademyMeta {
	r.mu.RLock()
	defer r.mu.RUnlock()

	result := make([]*AcademyMeta, 0, len(r.academies))
	for _, a := range r.academies {
		result = append(result, a)
	}
	return result
}

func (r *ContentRegistry) GetSpecializations(academyID string) []*SpecializationMeta {
	r.mu.RLock()
	defer r.mu.RUnlock()

	result := make([]*SpecializationMeta, 0)
	for _, s := range r.specializations {
		if academyID == "" || s.AcademyID == academyID {
			result = append(result, s)
		}
	}
	return result
}

func (r *ContentRegistry) GetPackPath(packID string) (string, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	path, ok := r.packPaths[packID]
	return path, ok
}
