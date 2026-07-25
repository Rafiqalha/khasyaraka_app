package catalog

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
)

// --- BLUEPRINT MODELS (Filesystem-First 5-Layer Hierarchy) ---

type AcademyBlueprint struct {
	ID          string   `yaml:"id" json:"id"`
	Title       string   `yaml:"title" json:"title"`
	Icon        string   `yaml:"icon" json:"icon"`
	ColorTheme  string   `yaml:"color_theme" json:"color_theme"`
	Description string   `yaml:"description" json:"description"`
	Order       int      `yaml:"order" json:"order"`
	Path        string   `json:"path"`
}

type SpecializationBlueprint struct {
	ID            string   `yaml:"id" json:"id"`
	AcademyID     string   `yaml:"academy_id" json:"academy_id"`
	Title         string   `yaml:"title" json:"title"`
	Description   string   `yaml:"description" json:"description"`
	Prerequisites []string `yaml:"prerequisites" json:"prerequisites"`
	Order         int      `yaml:"order" json:"order"`
	Path          string   `json:"path"`
}

type ExperienceBlueprint struct {
	ID               string   `yaml:"id" json:"id"`
	SpecializationID string   `yaml:"specialization_id" json:"specialization_id"`
	Title            string   `yaml:"title" json:"title"`
	Description      string   `yaml:"description" json:"description"`
	Packs            []string `yaml:"packs" json:"packs"`
	Capstones        []string `yaml:"capstones" json:"capstones"`
	ContentHash      string   `json:"content_hash"`
	Path             string   `json:"path"`
}

type PackBlueprint struct {
	ID             string                  `yaml:"id" json:"id"`
	Version        string                  `yaml:"version" json:"version"`
	Title          string                  `yaml:"title" json:"title"`
	Description    string                  `yaml:"description" json:"description"`
	Icon           string                  `yaml:"icon" json:"icon"`
	Difficulty     string                  `yaml:"difficulty" json:"difficulty"`
	EstimatedMinutes int                   `yaml:"estimated_minutes" json:"estimated_minutes"`
	WorkspaceRef   string                  `yaml:"workspace_ref" json:"workspace_ref"`
	Knowledge      *KnowledgeBlueprint      `yaml:"knowledge" json:"knowledge,omitempty"`
	Workspace      *WorkspaceBlueprint      `yaml:"workspace" json:"workspace,omitempty"`
	Assessment     *AssessmentBlueprint     `yaml:"assessment" json:"assessment,omitempty"`
	Missions       []*MissionBlueprint     `yaml:"missions" json:"missions"`
	ContentHash    string                  `json:"content_hash"`
	Path           string                  `json:"path"`
}

type MissionBlueprint struct {
	ID             string            `yaml:"id" json:"id"`
	Title          string            `yaml:"title" json:"title"`
	Type           string            `yaml:"type" json:"type"`
	Objective      string            `yaml:"objective" json:"objective"`
	Instructions   string            `yaml:"instructions" json:"instructions"`
	Difficulty     string            `yaml:"difficulty" json:"difficulty"`
	EstimatedSecs  int               `yaml:"estimated_seconds" json:"estimated_seconds"`
	IsRequired     bool              `yaml:"is_required" json:"is_required"`
	TelemetryKey   string            `yaml:"telemetry_key" json:"telemetry_key"`
	CompetencyKeys []string          `yaml:"competency_keys" json:"competency_keys"`
	Validator      map[string]any    `yaml:"validator" json:"validator"`
	Hints          []string          `yaml:"hints" json:"hints"`
}

type KnowledgeBlueprint struct {
	Nodes []KnowledgeNodeBlueprint `yaml:"nodes" json:"nodes"`
	Edges []KnowledgeEdgeBlueprint `yaml:"edges" json:"edges"`
}

type KnowledgeNodeBlueprint struct {
	ID          string  `yaml:"id" json:"id"`
	Name        string  `yaml:"name" json:"name"`
	TargetScore float64 `yaml:"target_score" json:"target_score"`
}

type KnowledgeEdgeBlueprint struct {
	From string `yaml:"from" json:"from"`
	To   string `yaml:"to" json:"to"`
}

type WorkspaceBlueprint struct {
	ID           string   `yaml:"id" json:"id"`
	Driver       string   `yaml:"driver" json:"driver"`
	Image        string   `yaml:"image" json:"image"`
	Capabilities []string `yaml:"capabilities" json:"capabilities"`
	Panels       []string `yaml:"panels" json:"panels"`
}

type AssessmentBlueprint struct {
	PassThreshold float64        `yaml:"pass_threshold" json:"pass_threshold"`
	Rubric        map[string]any `yaml:"rubric" json:"rubric"`
}

// ComputeDirSHA256 calculates a deterministic SHA-256 content hash over all files in a directory.
func ComputeDirSHA256(dirPath string) (string, error) {
	hasher := sha256.New()
	var filePaths []string

	err := filepath.Walk(dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil || info.IsDir() {
			return err
		}
		filePaths = append(filePaths, path)
		return nil
	})
	if err != nil {
		return "", fmt.Errorf("failed to walk dir %s: %w", dirPath, err)
	}

	sort.Strings(filePaths)

	for _, p := range filePaths {
		relPath, _ := filepath.Rel(dirPath, p)
		hasher.Write([]byte(relPath))

		f, err := os.Open(p)
		if err != nil {
			return "", err
		}
		if _, err := io.Copy(hasher, f); err != nil {
			f.Close()
			return "", err
		}
		f.Close()
	}

	return hex.EncodeToString(hasher.Sum(nil)), nil
}
