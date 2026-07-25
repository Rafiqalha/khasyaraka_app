package pack

import "context"

// Loader is responsible for converting a BlueprintURI from a PackDescriptor
// into a fully populated Pack struct.
// Implementations could be FilesystemLoader, MarketplaceLoader, DatabaseLoader.
type Loader interface {
	// Load fetches and parses the blueprint artifacts into a pure Go struct.
	Load(ctx context.Context, descriptor *PackDescriptor) (*Pack, error)
}
