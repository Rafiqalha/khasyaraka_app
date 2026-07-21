package competency_graph

import (
	"context"
	"time"

	"github.com/oklog/ulid/v2"
)

type Priority string

const (
	PriorityHigh   Priority = "HIGH"
	PriorityNormal Priority = "NORMAL"
	PriorityLow    Priority = "LOW"
)

type ProjectionJob struct {
	ID          string    `db:"id" json:"id"`
	UserID      string    `db:"user_id" json:"user_id"`
	Priority    Priority  `db:"priority" json:"priority"`
	Status      string    `db:"status" json:"status"`
	Reason      string    `db:"reason" json:"reason"`
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
	ProcessedAt *time.Time `db:"processed_at" json:"processed_at"`
}

type Scheduler interface {
	QueueJob(ctx context.Context, userID string, priority Priority, reason string) error
	ProcessJobs(ctx context.Context) error
}

type scheduler struct {
	repo Repository
	// projectionEngine ProjectionEngine
}

func NewScheduler(repo Repository) Scheduler {
	return &scheduler{repo: repo}
}

func (s *scheduler) QueueJob(ctx context.Context, userID string, priority Priority, reason string) error {
	job := ProjectionJob{
		ID:        ulid.Make().String(),
		UserID:    userID,
		Priority:  priority,
		Status:    "PENDING",
		Reason:    reason,
		CreatedAt: time.Time{},
	}
	// r.repo.SaveJob(...) 
	_ = job
	return nil
}

func (s *scheduler) ProcessJobs(ctx context.Context) error {
	// Fetch HIGH priority, then NORMAL, then LOW
	// Run ProjectionEngine for each user
	// Update job status
	return nil
}
