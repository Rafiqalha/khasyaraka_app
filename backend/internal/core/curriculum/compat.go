// Package curriculum is DEPRECATED.
// This is a compatibility layer. All new development should use the 'blueprint' package.
package curriculum

import "github.com/pradigi/backend/internal/core/blueprint"

// Curriculum is an alias for Blueprint to maintain backwards compatibility during migration.
type Curriculum = blueprint.Blueprint

// Parser is an alias for Blueprint Parser.
type Parser = blueprint.Parser

func NewParser(baseDir string) *Parser {
	return blueprint.NewParser(baseDir)
}
