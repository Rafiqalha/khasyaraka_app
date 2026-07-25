package worker

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/hibiken/asynq"
	"github.com/pradigi/backend/internal/core/director"
	"github.com/pradigi/backend/internal/core/evaluation"
	"github.com/pradigi/backend/internal/core/knowledge"
	"github.com/pradigi/backend/internal/sandbox"
	"github.com/rs/zerolog"
)

type Processor struct {
	server       *asynq.Server
	repo         *evaluation.Repository
	directorSvc  *director.Service
	knowledgeEng *knowledge.Engine
	pool         sandbox.RunnerPool
	logger       zerolog.Logger
}

func NewProcessor(redisOpt asynq.RedisConnOpt, repo *evaluation.Repository, directorSvc *director.Service, knowledgeEng *knowledge.Engine, pool sandbox.RunnerPool, logger zerolog.Logger) *Processor {
	srv := asynq.NewServer(
		redisOpt,
		asynq.Config{
			Concurrency: 10,
			Queues: map[string]int{
				"critical": 6,
				"high":     3,
				"default":  2,
				"low":      1,
			},
			Logger: &asynqLogger{logger: logger},
			ErrorHandler: asynq.ErrorHandlerFunc(func(ctx context.Context, task *asynq.Task, err error) {
				logger.Error().Err(err).Str("type", task.Type()).Msg("Task processing failed")
			}),
		},
	)

	return &Processor{
		server:       srv,
		repo:         repo,
		directorSvc:  directorSvc,
		knowledgeEng: knowledgeEng,
		pool:         pool,
		logger:       logger,
	}
}

func (p *Processor) Start() error {
	mux := asynq.NewServeMux()
	mux.HandleFunc(evaluation.TaskTypeEvaluateSubmission, p.ProcessEvaluateSubmission)
	mux.HandleFunc("knowledge:process_event", p.knowledgeEng.ProcessEvent)
	mux.HandleFunc("director:generate_insight", p.ProcessGenerateInsight)

	// Start blocks until server is stopped
	return p.server.Start(mux)
}

func (p *Processor) Stop() {
	p.server.Stop()
}

func (p *Processor) ProcessEvaluateSubmission(ctx context.Context, t *asynq.Task) error {
	var payload evaluation.EvaluateSubmissionPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("json.Unmarshal failed: %v: %w", err, asynq.SkipRetry)
	}

	p.logger.Info().
		Str("trace_id", payload.CorrelationID). // Treat CorrelationID as TraceID for now
		Str("correlation_id", payload.CorrelationID).
		Str("submission_id", payload.SubmissionID).
		Str("worker_id", "worker-1"). // Mock for now
		Msg("Worker picked up submission evaluation")

	// 1. WorkerAssigned -> PREPARING_SANDBOX
	err := p.repo.UpdateStatusWithEvent(ctx, payload.SubmissionID, evaluation.StatusQueued, evaluation.StatusPreparingSandbox, "WorkerAssigned", nil, nil, nil)
	if err != nil {
		p.logger.Warn().Err(err).Msg("Failed to update status to PreparingSandbox")
	}

	startAlloc := time.Now()
	// Acquire Sandbox
	runner, err := p.pool.Acquire(ctx, payload.Language)
	if err != nil {
		p.logger.Error().Err(err).Msg("Failed to acquire sandbox")
		p.repo.UpdateStatusWithEvent(ctx, payload.SubmissionID, evaluation.StatusPreparingSandbox, evaluation.StatusRetrying, "SandboxAcquireFailed", err.Error(), nil, nil)
		// This is an infrastructure error, so we DO NOT return asynq.SkipRetry. We want it to retry.
		return fmt.Errorf("acquire sandbox: %w", err)
	}
	defer p.pool.Release(runner)

	durAlloc := int(time.Since(startAlloc).Milliseconds())
	p.repo.UpdateStatusWithEvent(ctx, payload.SubmissionID, evaluation.StatusPreparingSandbox, evaluation.StatusRunning, "SandboxAllocated", nil, &durAlloc, nil)

	startExec := time.Now()

	// Execute Code
	req := sandbox.ExecutionRequest{
		Code:     payload.SourceCode,
		Language: payload.Language,
		Timeout:  2 * time.Second, // Sandbox timeout is 2s
	}

	result, err := runner.Execute(ctx, req)
	durExec := int(time.Since(startExec).Milliseconds())

	if err != nil {
		p.repo.UpdateStatusWithEvent(ctx, payload.SubmissionID, evaluation.StatusRunning, evaluation.StatusFailed, "ExecutionError", err.Error(), &durExec, nil)
		// Usually execution errors are from the user's code, but if it's a Docker failure we might want to retry.
		// For MVP, assume it's a compile/user error and skip retry.
		return fmt.Errorf("execute code: %w: %v", err, asynq.SkipRetry)
	}

	p.repo.UpdateStatusWithEvent(ctx, payload.SubmissionID, evaluation.StatusRunning, evaluation.StatusValidatingOutput, "ExecutionFinished", result, &durExec, nil)

	startEval := time.Now()

	// Here we would call the Evaluator -> Evidence Extractor -> Competency Updater.
	// For now, we simulate this pipeline to update states properly.
	time.Sleep(10 * time.Millisecond)

	durEval := int(time.Since(startEval).Milliseconds())
	p.repo.UpdateStatusWithEvent(ctx, payload.SubmissionID, evaluation.StatusValidatingOutput, evaluation.StatusCompleted, "SubmissionCompleted", nil, &durEval, nil)

	p.logger.Info().
		Str("trace_id", payload.CorrelationID).
		Str("correlation_id", payload.CorrelationID).
		Str("submission_id", payload.SubmissionID).
		Str("worker_id", "worker-1").
		Msg("Worker finished submission evaluation successfully")

	return nil
}

// Wrapper to adapt zerolog to asynq.Logger
type asynqLogger struct {
	logger zerolog.Logger
}

func (l *asynqLogger) Debug(args ...interface{}) { l.logger.Debug().Msg(fmt.Sprint(args...)) }
func (l *asynqLogger) Info(args ...interface{})  { l.logger.Info().Msg(fmt.Sprint(args...)) }
func (l *asynqLogger) Warn(args ...interface{})  { l.logger.Warn().Msg(fmt.Sprint(args...)) }
func (l *asynqLogger) Error(args ...interface{}) { l.logger.Error().Msg(fmt.Sprint(args...)) }
func (l *asynqLogger) Fatal(args ...interface{}) { l.logger.Fatal().Msg(fmt.Sprint(args...)) }

func (p *Processor) ProcessGenerateInsight(ctx context.Context, t *asynq.Task) error {
	var payload map[string]interface{}
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("json.Unmarshal failed: %v", err)
	}

	userID, ok := payload["user_id"].(string)
	if !ok || userID == "" {
		return fmt.Errorf("user_id missing or invalid")
	}

	p.logger.Info().Str("user", userID).Msg("Processing AI Director insight")
	err := p.directorSvc.GenerateInsight(ctx, userID)
	if err != nil {
		p.logger.Error().Err(err).Msg("Director failed to generate insight")
		return err
	}

	return nil
}
