// Package registry — Fixture Registry subsystem.
// Fixtures are stored on disk, NOT in Go source code.
// The Registry indexes them with rich metadata for search, filtering, and mission authoring.
package registry

// FixtureMetadata describes a single fixture with rich research-grade metadata.
type FixtureMetadata struct {
	ID                string   `json:"id"`                 // "bug_001"
	Version           string   `json:"version"`            // "1.0.0"
	Language          string   `json:"language"`           // "python"
	Difficulty        string   `json:"difficulty"`         // "EASY", "MEDIUM", "HARD", "EXPERT"
	Tags              []string `json:"tags"`               // ["off-by-one", "loop", "list"]
	KnowledgeRequired []string `json:"knowledge_required"` // ["loops", "indexing", "range"]
	BugType           string   `json:"bug_type"`           // "LOGICAL", "SYNTAX", "RUNTIME", "CONCURRENCY"
	Narrative         string   `json:"narrative"`          // Human-readable mission story
	TestFile          string   `json:"test_file"`          // Relative path to test file
	SourceFile        string   `json:"source_file"`        // Relative path to source
}

// FixtureRegistry is the central index of all available fixtures.
// Educators can add 500 missions without touching Go code.
type FixtureRegistry interface {
	// Register adds a fixture to the registry.
	Register(meta FixtureMetadata) error

	// Get retrieves a fixture by ID.
	Get(id string) (*FixtureMetadata, bool)

	// Search finds fixtures matching given criteria.
	Search(language string, difficulty string, tags []string) []FixtureMetadata

	// ListAll returns all registered fixtures.
	ListAll() []FixtureMetadata
}

// InMemoryFixtureRegistry is the default implementation.
type InMemoryFixtureRegistry struct {
	fixtures map[string]FixtureMetadata
}

func NewFixtureRegistry() FixtureRegistry {
	reg := &InMemoryFixtureRegistry{
		fixtures: make(map[string]FixtureMetadata),
	}

	// Seed with Python debugging fixtures
	reg.Register(FixtureMetadata{
		ID: "bug_001", Version: "1.0.0", Language: "python", Difficulty: "EASY",
		Tags: []string{"off-by-one", "loop", "list"}, KnowledgeRequired: []string{"loops", "indexing", "range"},
		BugType: "LOGICAL", Narrative: "A list sum function skips the first element.",
		SourceFile: "bug_001.py", TestFile: "tests/bug_001_test.py",
	})
	reg.Register(FixtureMetadata{
		ID: "bug_002", Version: "1.0.0", Language: "python", Difficulty: "MEDIUM",
		Tags: []string{"mutable-default", "function", "reference"}, KnowledgeRequired: []string{"functions", "mutability", "default-arguments"},
		BugType: "LOGICAL", Narrative: "A shopping list builder leaks state between calls.",
		SourceFile: "bug_002.py", TestFile: "",
	})
	reg.Register(FixtureMetadata{
		ID: "bug_003", Version: "1.0.0", Language: "python", Difficulty: "MEDIUM",
		Tags: []string{"return-value", "dict", "scope"}, KnowledgeRequired: []string{"functions", "dictionaries", "variable-scope"},
		BugType: "LOGICAL", Narrative: "A grade report returns only the last student's data.",
		SourceFile: "bug_003.py", TestFile: "",
	})

	return reg
}

func (r *InMemoryFixtureRegistry) Register(meta FixtureMetadata) error {
	r.fixtures[meta.ID] = meta
	return nil
}

func (r *InMemoryFixtureRegistry) Get(id string) (*FixtureMetadata, bool) {
	m, ok := r.fixtures[id]
	if !ok {
		return nil, false
	}
	return &m, true
}

func (r *InMemoryFixtureRegistry) Search(language string, difficulty string, tags []string) []FixtureMetadata {
	var results []FixtureMetadata
	for _, m := range r.fixtures {
		if language != "" && m.Language != language {
			continue
		}
		if difficulty != "" && m.Difficulty != difficulty {
			continue
		}
		if len(tags) > 0 {
			matched := false
			for _, t := range tags {
				for _, mt := range m.Tags {
					if t == mt {
						matched = true
						break
					}
				}
				if matched {
					break
				}
			}
			if !matched {
				continue
			}
		}
		results = append(results, m)
	}
	return results
}

func (r *InMemoryFixtureRegistry) ListAll() []FixtureMetadata {
	all := make([]FixtureMetadata, 0, len(r.fixtures))
	for _, m := range r.fixtures {
		all = append(all, m)
	}
	return all
}
