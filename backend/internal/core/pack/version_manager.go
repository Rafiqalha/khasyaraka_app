package pack

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

// CalculateChecksum computes a deterministic SHA256 checksum for a loaded Pack blueprint.
func CalculateChecksum(p *Pack) string {
	hasher := sha256.New()
	hasher.Write([]byte(p.Descriptor.ID))
	hasher.Write([]byte(p.Descriptor.Version))
	hasher.Write([]byte(p.Title))
	for _, m := range p.Missions {
		hasher.Write([]byte(m.ID))
		hasher.Write([]byte(m.Title))
	}
	return hex.EncodeToString(hasher.Sum(nil))
}

type VersionManager struct {
	versions map[string]*Pack // Key: PackID:Version
}

func NewVersionManager() *VersionManager {
	return &VersionManager{
		versions: make(map[string]*Pack),
	}
}

func (vm *VersionManager) Register(p *Pack) {
	key := fmt.Sprintf("%s:%s", p.Descriptor.ID, p.Descriptor.Version)
	p.Checksum = CalculateChecksum(p)
	vm.versions[key] = p
}

func (vm *VersionManager) Get(packID, version string) (*Pack, bool) {
	key := fmt.Sprintf("%s:%s", packID, version)
	p, ok := vm.versions[key]
	return p, ok
}
