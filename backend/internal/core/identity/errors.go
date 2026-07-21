package identity

import "errors"

var (
	ErrProfileNotFound = errors.New("learner profile not found")
	ErrInvalidPersona  = errors.New("invalid AI persona")
	ErrInvalidStage    = errors.New("invalid learning stage")
	ErrInvalidGoal     = errors.New("invalid learning goal type")
	ErrInvalidCapability = errors.New("invalid device capability score")
)
