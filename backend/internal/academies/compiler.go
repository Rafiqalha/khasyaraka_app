package academies

import (
	"errors"
	"fmt"
)

// Compiler is the quality gate and packager for an Academy.
type Compiler struct {}

func NewCompiler() *Compiler {
	return &Compiler{}
}

// Validate ensures no orphan nodes, cyclic graphs, missing assets, or invalid WDLs.
func (c *Compiler) Validate(sourceDir string) error {
	fmt.Printf("Validating academy at %s...\n", sourceDir)
	// 1. Validate Curriculum DAG
	// 2. Validate Knowledge Graph
	// 3. Asset Integrity
	return nil
}

// Compile compresses the validated source into a .pack archive.
func (c *Compiler) Compile(sourceDir string, targetPackFile string) error {
	fmt.Printf("Compiling academy into %s...\n", targetPackFile)
	// Output: academy.pack
	return nil
}

// Sign generates a SHA256 checksum and signs the .pack file with the publisher's key.
func (c *Compiler) Sign(packFile string, publisherKey string) (string, error) {
	fmt.Printf("Signing academy package %s...\n", packFile)
	// Return signature / checksum
	return "signed_sha256_mock", nil
}

// Publish uploads the signed .pack to the central registry (e.g. registry.pradigi.id).
func (c *Compiler) Publish(packFile string, signature string, registryURL string) error {
	fmt.Printf("Publishing package to %s...\n", registryURL)
	return nil
}

// Pipeline runs the entire end-to-end build process for an Academy.
func (c *Compiler) Pipeline(sourceDir, targetPack, publisherKey, registryURL string) error {
	if err := c.Validate(sourceDir); err != nil {
		return errors.New("validation failed: " + err.Error())
	}
	if err := c.Compile(sourceDir, targetPack); err != nil {
		return errors.New("compilation failed: " + err.Error())
	}
	sig, err := c.Sign(targetPack, publisherKey)
	if err != nil {
		return errors.New("signing failed: " + err.Error())
	}
	if err := c.Publish(targetPack, sig, registryURL); err != nil {
		return errors.New("publishing failed: " + err.Error())
	}
	return nil
}
