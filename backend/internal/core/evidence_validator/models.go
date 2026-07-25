package evidence_validator

import (
	"time"
)

type Verdict string

const (
	VerdictPassed            Verdict = "PASSED"
	VerdictWrongAnswer       Verdict = "WRONG_ANSWER"
	VerdictCompileError      Verdict = "COMPILE_ERROR"
	VerdictRuntimeError      Verdict = "RUNTIME_ERROR"
	VerdictTimeLimit         Verdict = "TIME_LIMIT"
	VerdictMemoryLimit       Verdict = "MEMORY_LIMIT"
	VerdictSecurityViolation Verdict = "SECURITY_VIOLATION"
)

type CodeSnapshot struct {
	ID       string `json:"id"`
	Language string `json:"language"`
	Source   string `json:"source"`
	SHA256   string `json:"sha256"`
}

type TestCaseVisibility string

const (
	VisibilityPublic TestCaseVisibility = "public"
	VisibilityHidden TestCaseVisibility = "hidden"
)

type TestCase struct {
	ID         string             `json:"id"`
	Visibility TestCaseVisibility `json:"visibility"`
	Input      []interface{}      `json:"input"`
	Expected   interface{}        `json:"expected"`
	Weight     int                `json:"weight"`
}

type TestSummary struct {
	Total        int `json:"total"`
	Passed       int `json:"passed"`
	Failed       int `json:"failed"`
	HiddenPassed int `json:"hiddenPassed"`
}

type RecommendationAction string

const (
	ActionProceed   RecommendationAction = "PROCEED"
	ActionRemediate RecommendationAction = "REMEDIATE"
	ActionReview    RecommendationAction = "REVIEW"
)

type Recommendation struct {
	Action     RecommendationAction `json:"action"`
	TargetNode string               `json:"targetNode"`
	Reason     string               `json:"reason"`
	Priority   int                  `json:"priority"`
	Message    string               `json:"message"`
}

// SubmissionStatus defines the strict state machine for a submission
type SubmissionStatus string

const (
	StatusQueued               SubmissionStatus = "QUEUED"
	StatusPreparingSandbox     SubmissionStatus = "PREPARING_SANDBOX"
	StatusRunning              SubmissionStatus = "RUNNING"
	StatusValidatingOutput     SubmissionStatus = "VALIDATING_OUTPUT"
	StatusExtractingEvidence   SubmissionStatus = "EXTRACTING_EVIDENCE"
	StatusUpdatingCompetency   SubmissionStatus = "UPDATING_COMPETENCY"
	StatusRecommendingNextNode SubmissionStatus = "RECOMMENDING_NEXT_NODE"
	StatusCompleted            SubmissionStatus = "COMPLETED"

	// Error branches
	StatusFailed            SubmissionStatus = "FAILED"
	StatusTimeout           SubmissionStatus = "TIMEOUT"
	StatusSecurityViolation SubmissionStatus = "SECURITY_VIOLATION"
	StatusCancelled         SubmissionStatus = "CANCELLED"
	StatusRetrying          SubmissionStatus = "RETRYING"
	StatusExpired           SubmissionStatus = "EXPIRED"
)

type Submission struct {
	ID                string           `json:"id" db:"id"`
	CorrelationID     string           `json:"correlationId" db:"correlation_id"`
	UserID            string           `json:"userId" db:"user_id"`
	LearningSessionID string           `json:"learningSessionId" db:"learning_session_id"`
	MissionID         string           `json:"missionId" db:"mission_id"`
	NodeID            string           `json:"nodeId" db:"node_id"`
	AttemptNumber     int              `json:"attemptNumber" db:"attempt_number"`
	Priority          string           `json:"priority" db:"priority"`
	Status            SubmissionStatus `json:"status" db:"status"`
	IdempotencyKey    *string          `json:"idempotencyKey,omitempty" db:"idempotency_key"`

	RuleSetVersion    *string `json:"ruleSetVersion,omitempty" db:"rule_set_version"`
	EvaluatorVersion  *string `json:"evaluatorVersion,omitempty" db:"evaluator_version"`
	PolicyVersion     *string `json:"policyVersion,omitempty" db:"policy_version"`
	CurriculumVersion *string `json:"curriculumVersion,omitempty" db:"curriculum_version"`
	MissionVersion    *string `json:"missionVersion,omitempty" db:"mission_version"`
	SandboxImage      *string `json:"sandboxImage,omitempty" db:"sandbox_image"`

	WorkerID  *string `json:"workerId,omitempty" db:"worker_id"`
	QueueName *string `json:"queueName,omitempty" db:"queue_name"`

	CreatedAt   time.Time  `json:"createdAt" db:"created_at"`
	QueuedAt    *time.Time `json:"queuedAt,omitempty" db:"queued_at"`
	StartedAt   *time.Time `json:"startedAt,omitempty" db:"started_at"`
	CompletedAt *time.Time `json:"completedAt,omitempty" db:"completed_at"`
}

type SubmissionEvent struct {
	ID             string           `json:"id" db:"id"`
	SubmissionID   string           `json:"submissionId" db:"submission_id"`
	EventID        string           `json:"eventId" db:"event_id"`
	SequenceNumber int              `json:"sequenceNumber" db:"sequence_number"`
	PreviousStatus *string          `json:"previousStatus,omitempty" db:"previous_status"`
	NewStatus      SubmissionStatus `json:"newStatus" db:"new_status"`
	DurationMs     *int             `json:"durationMs,omitempty" db:"duration_ms"`
	Actor          *string          `json:"actor,omitempty" db:"actor"`
	Payload        []byte           `json:"payload,omitempty" db:"payload"`
	CreatedAt      time.Time        `json:"createdAt" db:"created_at"`
}
