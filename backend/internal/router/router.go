package router

import (
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"

	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/core/health"
	"github.com/pradigi/backend/internal/middleware"
	"github.com/pradigi/backend/internal/sandbox"
)

// New initializes the Gin HTTP engine, mounts global middlewares,
// and delegates route registration to modular route domain handlers.
func New(
	cfg *config.Config,
	db *sqlx.DB,
	rdb *redis.Client,
	pool sandbox.RunnerPool,
	asynqClient *asynq.Client,
) *gin.Engine {
	r := gin.New()

	if len(cfg.TrustedProxies) > 0 {
		_ = r.SetTrustedProxies(cfg.TrustedProxies)
	} else {
		_ = r.SetTrustedProxies(nil)
	}

	// Global Security & Observability Middlewares
	r.Use(middleware.Recovery())
	r.Use(middleware.SecurityHeaders())
	r.Use(middleware.CorrelationID())
	r.Use(middleware.CORS(cfg.CORSOrigins))
	r.Use(middleware.Logger())

	// Platform Health & Liveness Endpoints
	healthH := health.NewHandler(db, pool)
	r.GET("/live", healthH.Live)
	r.GET("/ready", healthH.Ready)
	r.GET("/health/details", healthH.Details)

	// API Groups
	api := r.Group("/api/v1")
	api.GET("/health", healthHandler(db, rdb))

	// 1. Core V2 (G2 Learning OS & Catalog)
	registerV2Routes(r, cfg, db, rdb, pool, asynqClient)

	// 2. Core V1 (Auth, Users, Training, Submissions/Sandbox, Telemetry)
	registerV1Routes(api, cfg, db, rdb, pool, asynqClient)

	// 3. Legacy Compatibility Layer (Deprecated modules)
	registerLegacyRoutes(api, cfg, db, rdb)

	return r
}
