package curriculum

import (
	"fmt"
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// Parser parses a Curriculum Manifest from the filesystem.
type Parser struct {
	baseDir string
}

func NewParser(baseDir string) *Parser {
	return &Parser{baseDir: baseDir}
}

// Parse loads the curriculum.yaml and all referenced units/lessons.
func (p *Parser) Parse(academyID, curriculumID string) (*Curriculum, error) {
	currDir := filepath.Join(p.baseDir, "academies", academyID, "curriculum", curriculumID)
	currFile := filepath.Join(currDir, "curriculum.yaml")

	data, err := os.ReadFile(currFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read curriculum manifest: %w", err)
	}

	var curriculum Curriculum
	if err := yaml.Unmarshal(data, &curriculum); err != nil {
		return nil, fmt.Errorf("failed to parse curriculum manifest: %w", err)
	}

	curriculum.AcademyID = academyID
	curriculum.ID = curriculumID

	// Hydrate Units
	for i, unit := range curriculum.Units {
		hydratedUnit, err := p.parseUnit(currDir, unit.ID)
		if err != nil {
			return nil, err
		}
		curriculum.Units[i] = *hydratedUnit
	}

	return &curriculum, nil
}

func (p *Parser) parseUnit(currDir, unitID string) (*Unit, error) {
	unitDir := filepath.Join(currDir, "units", unitID)
	// We might have a unit.yaml or we just scan the directory.
	// For simplicity, let's assume unit metadata is in curriculum.yaml, 
	// and we just need to parse the lessons within the unit dir.

	entries, err := os.ReadDir(unitDir)
	if err != nil {
		return nil, fmt.Errorf("failed to read unit directory %s: %w", unitID, err)
	}

	var unit Unit
	unit.ID = unitID
	unit.Lessons = make([]Lesson, 0)

	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".yaml" {
			continue
		}
		// Expecting lesson files like `arrays_lesson.yaml`
		lessonFile := filepath.Join(unitDir, entry.Name())
		lessonData, err := os.ReadFile(lessonFile)
		if err != nil {
			continue
		}

		var lesson Lesson
		if err := yaml.Unmarshal(lessonData, &lesson); err == nil {
			unit.Lessons = append(unit.Lessons, lesson)
		}
	}

	return &unit, nil
}
