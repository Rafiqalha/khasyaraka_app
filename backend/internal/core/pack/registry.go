package pack

import "errors"

var ErrPackNotFound = errors.New("pack not found in registry")

// Registry acts as a package manager index, locating PackDescriptors.
// It does NOT load the full YAML blueprint, only finds where it lives.
type Registry interface {
	// Get finds a PackDescriptor by its unique ID.
	Get(id string) (*PackDescriptor, error)

	// Search finds packs based on query criteria (e.g., domain, publisher).
	Search(query string) ([]*PackDescriptor, error)

	// Installed returns a list of all currently installed packs.
	Installed() ([]*PackDescriptor, error)
}
