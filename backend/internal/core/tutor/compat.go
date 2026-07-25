// Package tutor is DEPRECATED.
// This is a compatibility layer. All new development should use the 'director' package.
package tutor

import "github.com/pradigi/backend/internal/core/director"

// FeedbackObject is an alias for Director FeedbackObject.
type FeedbackObject = director.FeedbackObject

// Service is an alias for Director TutorService.
type Service = director.TutorService

func NewService(apiKey string, modelName string) (*Service, error) {
	return director.NewTutorService(apiKey, modelName)
}
