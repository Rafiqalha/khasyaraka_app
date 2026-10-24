package router

import (
	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"

	"github.com/pradigi/backend/internal/academies/cyber/cyber"
	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/core/evidence_validator"
	"github.com/pradigi/backend/internal/core/telemetry"
	"github.com/pradigi/backend/internal/core/tutor"
	"github.com/pradigi/backend/internal/legacy/training"
	"github.com/pradigi/backend/internal/metrics"
	"github.com/pradigi/backend/internal/middleware"
	"github.com/pradigi/backend/internal/modules/auth"
	"github.com/pradigi/backend/internal/modules/users"
	"github.com/pradigi/backend/internal/sandbox"
)

// registerV1Routes registers active core v1 endpoints (Auth, Users, Training, Submissions/Sandbox, Telemetry).
func registerV1Routes(
	api *gin.RouterGroup,
	cfg *config.Config,
	db *sqlx.DB,
	rdb *redis.Client,
	pool sandbox.RunnerPool,
	asynqClient *asynq.Client,
) {
	// Telemetry & Metrics
	telemetryRepo := telemetry.NewRepository(db)
	metricsH := metrics.NewHandler(db, telemetryRepo)
	api.POST("/metrics/events", metricsH.TrackEvent)
	api.POST("/telemetry/batch", metricsH.TrackEpisode)

	// Auth Endpoints
	authRepo := auth.NewRepository(db)
	authSvc := auth.NewService(authRepo, cfg.JWTSecret, cfg.AccessTokenExpireMins)
	authH := auth.NewHandler(authSvc)

	authGroup := api.Group("/auth")
	{
		authGroup.POST("/register", authH.Register)
		authGroup.POST("/login", authH.Login)
		authGroup.POST("/google", authH.GoogleSignIn)
	}

	authProtected := api.Group("/auth")
	authProtected.Use(middleware.Auth(cfg.JWTSecret))
	{
		authProtected.POST("/change-password", authH.ChangePassword)
	}

	// User Profiles
	usersRepo := users.NewRepository(db)
	usersSvc := users.NewService(usersRepo)
	usersH := users.NewHandler(usersSvc)

	me := api.Group("/me")
	me.Use(middleware.Auth(cfg.JWTSecret))
	{
		me.GET("", usersH.GetMe)
		me.PATCH("/profile", usersH.UpdateProfile)
		me.POST("/avatar", usersH.UpdateAvatar)
	}
	api.GET("/users/:id/public", usersH.GetPublicProfile)

	// Training Curriculum (Consumed by Flutter)
	trainingRepo := training.NewRepository(db)
	trainingSvc := training.NewService(trainingRepo, rdb, db)
	trainingH := training.NewHandler(trainingSvc)

	api.GET("/training/courses", trainingH.ListCourses)
	api.GET("/training/sections", trainingH.ListSections)
	api.GET("/training/sections/:id", trainingH.GetSection)
	api.GET("/training/sections/:id/path", trainingH.GetLearningPath)
	api.GET("/training/units/:id", trainingH.GetUnit)
	api.GET("/training/units/:id/levels", trainingH.GetUnit)
	api.GET("/training/units/:id/questions", trainingH.GetUnitQuestions)
	api.GET("/training/levels/:id", trainingH.GetLevel)
	api.GET("/training/levels/:id/questions", trainingH.GetLevelQuestions)

	authTraining := api.Group("/training")
	authTraining.Use(middleware.Auth(cfg.JWTSecret))
	{
		authTraining.POST("/progress/submit", trainingH.SubmitProgress)
		authTraining.GET("/progress", trainingH.GetProgress)
		authTraining.GET("/progress/state", trainingH.GetProgress)
	}

	// Cyber Modules
	cyberRepo := cyber.NewRepository(db)
	cyberSvc := cyber.NewService(cyberRepo, rdb)
	cyberH := cyber.NewHandler(cyberSvc)

	api.GET("/cyber/modules", cyberH.ListModules)
	api.GET("/cyber/modules/:id", cyberH.GetModule)

	authCyber := api.Group("/cyber")
	authCyber.Use(middleware.Auth(cfg.JWTSecret))
	{
		authCyber.GET("/challenges/:id", cyberH.GetChallenge)
		authCyber.POST("/challenges/:id/solve", cyberH.SolveChallenge)
	}

	// Submissions & Evidence Validator (Code Sandbox Execution)
	evRepo := evidence_validator.NewRepository(db)
	evQueue := evidence_validator.NewQueueClientFromClient(asynqClient)
	tutorSvc, _ := tutor.NewService(cfg.DeepSeekAPIKey, cfg.DeepSeekModel)
	evHandler := evidence_validator.NewHandler(evQueue, evRepo, pool, tutorSvc)

	authSubmissions := api.Group("")
	authSubmissions.Use(middleware.Auth(cfg.JWTSecret))
	{
		authSubmissions.POST("/submissions", evHandler.Submit)
		authSubmissions.GET("/submissions/:id", evHandler.GetStatus)
	}
}
