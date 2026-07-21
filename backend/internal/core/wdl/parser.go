package wdl

import (
	"os"

	"gopkg.in/yaml.v3"
)

// Parser handles reading and unmarshaling WDL files.
type Parser struct{}

func NewParser() *Parser {
	return &Parser{}
}

// ParseFile reads a YAML file and converts it into a WorkspaceManifest.
func (p *Parser) ParseFile(filePath string) (*WorkspaceManifest, error) {
	data, err := os.ReadFile(filePath)
	if err != nil {
		return nil, err
	}

	var manifest WorkspaceManifest
	err = yaml.Unmarshal(data, &manifest)
	if err != nil {
		return nil, err
	}

	return &manifest, nil
}
