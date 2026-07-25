package pack

import (
	"os"
	"path/filepath"
	"strings"
)

// LocalRegistry implements Registry by scanning a local base directory (e.g., "academies/").
type LocalRegistry struct {
	basePath string
	index    map[string]*PackDescriptor
}

func NewLocalRegistry(basePath string) *LocalRegistry {
	r := &LocalRegistry{
		basePath: basePath,
		index:    make(map[string]*PackDescriptor),
	}
	r.scan() // Pre-scan on startup (could be async in production)
	return r
}

func (r *LocalRegistry) scan() {
	if _, err := os.Stat(filepath.Join(r.basePath, "ai_academy")); os.IsNotExist(err) {
		fallback := filepath.Join("..", r.basePath)
		if _, err := os.Stat(filepath.Join(fallback, "ai_academy")); err == nil {
			r.basePath = fallback
		}
	}

	// Register default fallback pack
	fallbackDesc := &PackDescriptor{
		ID:           "backend_engineering",
		Version:      "1.0.0",
		Publisher:    "Pradigi",
		Source:       "local",
		BlueprintURI: filepath.Join(r.basePath, "ai_academy", "packs", "backend_engineering"),
	}
	r.index["backend_engineering"] = fallbackDesc

	// Dynamically scan r.basePath ("academies") for manifest.yaml files
	_ = filepath.WalkDir(r.basePath, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return nil
		}
		if !d.IsDir() && d.Name() == "manifest.yaml" {
			dir := filepath.Dir(path)
			manifestBytes, err := os.ReadFile(path)
			packID := filepath.Base(dir)
			version := "1.0.0"

			if err == nil {
				for _, line := range strings.Split(string(manifestBytes), "\n") {
					line = strings.TrimSpace(line)
					if strings.HasPrefix(line, "id:") {
						packID = strings.TrimSpace(strings.TrimPrefix(line, "id:"))
						packID = strings.Trim(packID, `"'`)
					}
					if strings.HasPrefix(line, "version:") {
						version = strings.TrimSpace(strings.TrimPrefix(line, "version:"))
						version = strings.Trim(version, `"'`)
					}
				}
			}

			desc := &PackDescriptor{
				ID:           packID,
				Version:      version,
				Publisher:    "Pradigi",
				Source:       "local",
				BlueprintURI: dir,
			}
			r.index[packID] = desc
			r.index[filepath.Base(dir)] = desc
		}
		return nil
	})
}

func (r *LocalRegistry) Get(id string) (*PackDescriptor, error) {
	desc, exists := r.index[id]
	if !exists {
		if fallback, ok := r.index["backend_engineering"]; ok {
			return fallback, nil
		}
		for _, d := range r.index {
			return d, nil
		}
		return nil, ErrPackNotFound
	}
	return desc, nil
}

func (r *LocalRegistry) Search(query string) ([]*PackDescriptor, error) {
	var results []*PackDescriptor
	for _, desc := range r.index {
		if strings.Contains(strings.ToLower(desc.ID), strings.ToLower(query)) {
			results = append(results, desc)
		}
	}
	return results, nil
}

func (r *LocalRegistry) Installed() ([]*PackDescriptor, error) {
	var results []*PackDescriptor
	for _, desc := range r.index {
		results = append(results, desc)
	}
	return results, nil
}
