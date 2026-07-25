package evidence_validator

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/hibiken/asynq"
)

const (
	TaskTypeEvaluateSubmission = "submission:evaluate"
)

type EvaluateSubmissionPayload struct {
	SubmissionID      string `json:"submission_id"`
	LearningSessionID string `json:"learning_session_id"`
	MissionID         string `json:"mission_id"`
	SourceCode        string `json:"source_code"`
	Language          string `json:"language"`
	CorrelationID     string `json:"correlation_id"`
}

type QueueClient struct {
	client *asynq.Client
}

func NewQueueClient(redisOpt asynq.RedisConnOpt) *QueueClient {
	return &QueueClient{
		client: asynq.NewClient(redisOpt),
	}
}

func NewQueueClientFromClient(client *asynq.Client) *QueueClient {
	return &QueueClient{client: client}
}

func (q *QueueClient) EnqueueSubmissionEvaluation(ctx context.Context, payload EvaluateSubmissionPayload) error {
	b, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshal payload: %w", err)
	}

	task := asynq.NewTask(TaskTypeEvaluateSubmission, b)

	_, err = q.client.EnqueueContext(ctx, task,
		asynq.Queue("critical"),
		asynq.MaxRetry(3),
		asynq.Timeout(30*time.Second),
	)

	return err
}

func (q *QueueClient) Close() {
	q.client.Close()
}
