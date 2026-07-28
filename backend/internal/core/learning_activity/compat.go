// Package learning_activity is DEPRECATED.
// This is a compatibility layer. All new development should use the 'mission_specification' package.
package learning_activity

import "github.com/pradigi/backend/internal/core/mission_specification"

type LearningActivity = mission_specification.LearningActivity
type ActivityType = mission_specification.ActivityType

const (
	ActivityTyping  = mission_specification.ActivityTyping
	ActivityAIAsk   = mission_specification.ActivityAIAsk
	ActivityRun     = mission_specification.ActivityRun
	ActivityCompile = mission_specification.ActivityCompile
)
