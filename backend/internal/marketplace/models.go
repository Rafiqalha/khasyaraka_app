package marketplace

import "time"

// PackageManifest defines the rich metadata stored in manifest.yaml inside a .pack file.
type PackageManifest struct {
	ID          string `yaml:"id" json:"id"`
	Version     string `yaml:"version" json:"version"`
	Publisher   string `yaml:"publisher" json:"publisher"`
	Description string `yaml:"description" json:"description"`
	Engine      struct {
		Min string `yaml:"min" json:"min"`
		Max string `yaml:"max" json:"max"`
	} `yaml:"engine" json:"engine"`
	Dependencies []string `yaml:"dependencies" json:"dependencies"`
	Permissions  []string `yaml:"permissions" json:"permissions"` // e.g., "runtime", "notebook"
	Checksum     struct {
		SHA256 string `yaml:"sha256" json:"sha256"`
	} `yaml:"checksum" json:"checksum"`
	Signature struct {
		Publisher string `yaml:"publisher" json:"publisher"`
	} `yaml:"signature" json:"signature"`
}

// RegistryEntry is the metadata hosted on the Central Registry (e.g. registry.pradigi.id)
type RegistryEntry struct {
	ID               string    `json:"id" db:"id"`
	Version          string    `json:"version" db:"version"`
	PublisherID      string    `json:"publisher_id" db:"publisher_id"`
	Description      string    `json:"description" db:"description"`
	Tags             []string  `json:"tags"`
	License          string    `json:"license" db:"license"`
	Signature        string    `json:"signature" db:"signature"`
	Hash             string    `json:"hash" db:"hash"`
	Dependencies     []string  `json:"dependencies"`
	MinimumOSVersion string    `json:"minimum_os_version" db:"minimum_os_version"`
	DownloadURL      string    `json:"download_url" db:"download_url"`
	PublishedAt      time.Time `json:"published_at" db:"published_at"`
}

// Publisher represents an entity allowed to distribute packages.
type Publisher struct {
	ID                 string `json:"id" db:"id"`
	Name               string `json:"name" db:"name"`
	VerificationStatus string `json:"verification_status" db:"verification_status"` // e.g., "verified_official"
}
