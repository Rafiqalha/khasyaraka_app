package health

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/pradigi/backend/internal/sandbox"
)

type Handler struct {
	db   *sqlx.DB
	pool sandbox.RunnerPool
	// TODO: Add Redis client and Asynq inspector when queue is implemented
}

func NewHandler(db *sqlx.DB, pool sandbox.RunnerPool) *Handler {
	return &Handler{db: db, pool: pool}
}

// Live returns 200 OK if the HTTP server is up
func (h *Handler) Live(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// Ready returns 200 OK if critical dependencies (DB, Redis) are reachable
func (h *Handler) Ready(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	// Check DB
	if err := h.db.PingContext(ctx); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"status": "error", "postgres": "down"})
		return
	}

	// TODO: Check Redis

	c.JSON(http.StatusOK, gin.H{
		"status":   "ok",
		"postgres": "ok",
		"redis":    "ok", // Placeholder
	})
}

// Details returns comprehensive metrics for internal dashboards
func (h *Handler) Details(c *gin.Context) {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	dbStatus := "ok"
	if err := h.db.PingContext(ctx); err != nil {
		dbStatus = "down"
	}

	var poolMetrics sandbox.PoolMetrics
	if h.pool != nil {
		poolMetrics = h.pool.Metrics()
	}

	c.JSON(http.StatusOK, gin.H{
		"status":     "healthy",
		"postgres":   dbStatus,
		"redis":      "ok", // Placeholder
		"docker":     "ok", // Placeholder
		"queueDepth": 0,    // Placeholder
		"workers":    0,    // Placeholder
		"sandboxPool": gin.H{
			"idle":           poolMetrics.Idle,
			"busy":           poolMetrics.Busy,
			"draining":       poolMetrics.Draining,
			"creating":       poolMetrics.Creating,
			"avgAcquireMs":   poolMetrics.AvgAcquireMs,
			"avgExecutionMs": poolMetrics.AvgExecutionMs,
			"p95ExecutionMs": poolMetrics.P95ExecutionMs,
			"p99ExecutionMs": poolMetrics.P99ExecutionMs,
			"failureRate":    poolMetrics.FailureRate,
			"timeoutRate":    poolMetrics.TimeoutRate,
		},
		"dlq":     0, // Placeholder
		"version": "0.9.0-beta",
	})
}
