package academies

// AcademyManifest represents the academy.yaml definition
type AcademyManifest struct {
	ID      string `yaml:"id"`
	Name    string `yaml:"name"`
	Version string `yaml:"version"`
	Theme   struct {
		PrimaryColor string `yaml:"primary_color"`
	} `yaml:"theme"`
}

// Bundle represents a fully loaded Academy in memory.
// It acts as the registry item for the Pradigi Core.
type Bundle struct {
	Manifest       AcademyManifest
	CurriculumPath string
	KnowledgePath  string
	WorkspacePath  string
	IsCompiled     bool
}
