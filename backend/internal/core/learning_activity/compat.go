// Package learning_activity is DEPRECATED.
// This is a compatibility layer. All new development should use the 'mission_specification' package.
package learning_activity

import "github.com/pradigi/backend/internal/core/mission_specification"

// Manifest is an alias for Mission Specification.
type Manifest = mission_specification.Manifest

// Node represents the old concept of learning activity, alias for MissionNode.
type Node = mission_specification.Node

// Handler is an alias for the new Mission Specification handler
type Handler = mission_specification.Handler
