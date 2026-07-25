package sdk

// InstallReceipt represents the result of installing and indexing a .pack.
type InstallReceipt struct {
	PackID      string
	Version     string
	IndexStatus string // e.g. "SUCCESS", "FAILED"
	VectorSize  int
	NodeCount   int
}

// ValidationReport provides detailed diagnostics of a raw .pack folder structure.
type ValidationReport struct {
	IsValid bool
	Errors  []string
}

// PackSDK represents the public interface for the Pradigi Pack SDK.
// It is used by the Pack Installer (to load/index) and the Studio (to build/validate).
type PackSDK interface {
	// Validate checks a raw folder structure against the Pack Specification.
	Validate(path string) (*ValidationReport, error)

	// Build packages and signs a raw directory into a compressed .pack archive.
	Build(sourcePath string, destPath string, privateKey []byte) error

	// ReadManifest extracts and parses the manifest.yaml from a .pack without fully extracting it.
	ReadManifest(packPath string) (*Manifest, error)

	// Install extracts a .pack to a destination, runs the Knowledge Indexer (generating Vector & Skill Graphs),
	// and prepares it for Runtime execution.
	Install(packPath string, destDir string) (*InstallReceipt, error)
}
