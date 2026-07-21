package replay

import (
	"context"
	"errors"
)

type Planner interface {
	PlanReplayUser(ctx context.Context, userID string) (string, error)
	PlanReplaySession(ctx context.Context, sessionID string) (string, error)
}

type Worker interface {
	ProcessReplayJob(ctx context.Context, jobID string) error
}

type replayService struct {
	// dependencies like ObservationService, Repository, etc
}

func NewPlanner() Planner {
	return &replayService{}
}

func NewWorker() Worker {
	return &replayService{}
}

func (s *replayService) PlanReplayUser(ctx context.Context, userID string) (string, error) {
	// 1. Find all Sessions for User
	// 2. Find all Candidates
	// 3. Create Replay Tasks in DB
	// 4. Return JobID
	return "job_123", errors.New("not implemented")
}

func (s *replayService) PlanReplaySession(ctx context.Context, sessionID string) (string, error) {
	return "job_124", errors.New("not implemented")
}

func (s *replayService) ProcessReplayJob(ctx context.Context, jobID string) error {
	// 1. Fetch Tasks
	// 2. For each task:
	//    - Check InputFingerprint & ExecutionFingerprint (Idempotent Check)
	//    - If identical -> Skip or Link
	//    - If different -> Run ObservationEngine
	return errors.New("not implemented")
}
