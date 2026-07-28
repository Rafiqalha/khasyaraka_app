// Package evaluation is DEPRECATED.
// This is a compatibility layer. All new development should use the 'evidence_validator' package.
package evaluation

import "github.com/pradigi/backend/internal/core/evidence_validator"

type Evaluator = evidence_validator.Evaluator
type Repository = evidence_validator.Repository
type EvaluateSubmissionPayload = evidence_validator.EvaluateSubmissionPayload

const TaskTypeEvaluateSubmission = evidence_validator.TaskTypeEvaluateSubmission

const (
	StatusQueued           = evidence_validator.StatusQueued
	StatusPreparingSandbox = evidence_validator.StatusPreparingSandbox
	StatusRunning          = evidence_validator.StatusRunning
	StatusValidatingOutput = evidence_validator.StatusValidatingOutput
	StatusCompleted        = evidence_validator.StatusCompleted
	StatusFailed           = evidence_validator.StatusFailed
	StatusRetrying         = evidence_validator.StatusRetrying
)
