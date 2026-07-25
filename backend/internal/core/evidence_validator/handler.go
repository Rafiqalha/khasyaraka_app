package evidence_validator

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/pradigi/backend/internal/core/tutor"
	"github.com/pradigi/backend/internal/sandbox"
)

type Handler struct {
	queue *QueueClient
	repo  *Repository
	pool  sandbox.RunnerPool
	tutor *tutor.Service
}

func NewHandler(queue *QueueClient, repo *Repository, pool sandbox.RunnerPool, tutor *tutor.Service) *Handler {
	return &Handler{queue: queue, repo: repo, pool: pool, tutor: tutor}
}

type SubmissionRequest struct {
	LearningSessionID string `json:"learningSessionId" binding:"required"`
	MissionID         string `json:"nodeId" binding:"required"` // Maps from Flutter's nodeId
	Language          string `json:"language" binding:"required"`
	SourceCode        string `json:"code" binding:"required"` // Maps from Flutter's code
	Attempt           int    `json:"attempt"`
}

// Submit handles POST /api/v1/submissions
func (h *Handler) Submit(c *gin.Context) {
	var req SubmissionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	idempotencyKey := c.GetHeader("Idempotency-Key")
	if idempotencyKey != "" {
		existing, err := h.repo.GetIdempotentSubmission(c.Request.Context(), idempotencyKey)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "check idempotency failed"})
			return
		}
		if existing != nil {
			c.JSON(http.StatusOK, gin.H{
				"submissionId": existing.ID,
				"status":       existing.Status,
			})
			return
		}
	} else {
		// Auto-generate if missing for safety
		idempotencyKey = uuid.NewString()
	}

	correlationID := c.GetHeader("X-Correlation-ID")
	if correlationID == "" {
		correlationID = uuid.NewString()
	}

	now := time.Now()
	evalVersion := "2.0.1"
	userID := c.GetString("user_id")
	if userID == "" {
		userID = "demo-user"
	}

	sub := &Submission{
		ID:                uuid.NewString(),
		CorrelationID:     correlationID,
		UserID:            userID,
		LearningSessionID: req.LearningSessionID,
		MissionID:         req.MissionID,
		NodeID:            req.MissionID,
		AttemptNumber:     req.Attempt,
		Priority:          "critical",
		Status:            StatusQueued,
		IdempotencyKey:    &idempotencyKey,
		EvaluatorVersion:  &evalVersion,
		CreatedAt:         now,
		QueuedAt:          &now,
	}

	if err := h.repo.CreateSubmission(c.Request.Context(), sub); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Sprint YC: Synchronous Execution
	sub.Status = StatusRunning
	h.repo.UpdateStatusWithEvent(c.Request.Context(), sub.ID, StatusQueued, StatusRunning, "RunSandbox", nil, nil, nil)

	runner, err := h.pool.Acquire(c.Request.Context(), req.Language)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to acquire sandbox"})
		return
	}
	defer h.pool.Release(runner)

	execReq := sandbox.ExecutionRequest{
		Code:    req.SourceCode,
		Timeout: 5 * time.Second,
	}

	res, err := runner.Execute(c.Request.Context(), execReq)

	verdict := "FAILED"
	var feedback string
	var feedbackObj *tutor.FeedbackObject

	if err != nil {
		feedback = "Sandbox Execution Error: " + err.Error()
	} else {
		feedback = res.Stdout + "\n" + res.Stderr
		if res.ExitCode == 0 {
			verdict = "PASSED"
		} else if h.tutor != nil {
			// Trigger AI Tutor for error analysis
			aiResult, aiErr := h.tutor.AnalyzeError(c.Request.Context(), req.SourceCode, res.Stderr)
			if aiErr == nil && aiResult != nil {
				feedbackObj = aiResult
			} else {
				// Fallback if AI fails
				feedbackObj = &tutor.FeedbackObject{
					Diagnosis:  "Execution failed.",
					Suggestion: "Check the raw console output.",
				}
			}
		}
	}

	sub.Status = StatusCompleted

	// Create result payload
	resultPayload := gin.H{
		"submissionId": sub.ID,
		"verdict":      verdict,
		"feedback":     feedback,
		"evidence":     []interface{}{},
	}
	if feedbackObj != nil {
		resultPayload["ai_analysis"] = feedbackObj
	}

	h.repo.UpdateStatusWithEvent(c.Request.Context(), sub.ID, StatusRunning, StatusCompleted, "SandboxResult", resultPayload, nil, nil)

	c.JSON(http.StatusOK, gin.H{
		"submissionId": sub.ID,
		"status":       StatusCompleted,
		"progress":     100,
		"result":       resultPayload,
	})
}

// GetStatus handles GET /api/v1/submissions/:id
func (h *Handler) GetStatus(c *gin.Context) {
	id := c.Param("id")

	sub, err := h.repo.GetSubmissionByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if sub == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "submission not found"})
		return
	}

	// Dynamic progress mapping based on status
	var progress int
	var step string
	var result interface{}

	switch sub.Status {
	case StatusQueued:
		progress = 5
	case StatusPreparingSandbox:
		progress = 15
	case StatusRunning:
		progress = 45
	case StatusValidatingOutput:
		progress = 75
		step = "Validating Output"
	case StatusExtractingEvidence:
		progress = 85
		step = "Extracting Evidence"
	case StatusUpdatingCompetency:
		progress = 90
		step = "Updating Competency"
	case StatusRecommendingNextNode:
		progress = 95
		step = "Recommending Journey"
	case StatusCompleted:
		progress = 100
		step = "Completed"
		result = gin.H{
			"submissionId": sub.ID,
			"verdict":      "PASSED",
			"feedback":     "Great job!",
			"evidence":     []interface{}{},
		}
	default:
		progress = 100
	}

	c.JSON(http.StatusOK, gin.H{
		"submissionId": sub.ID,
		"status":       sub.Status,
		"progress":     progress,
		"step":         step,
		"result":       result,
	})
}
