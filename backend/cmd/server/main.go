package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	"github.com/hibiken/asynq"
	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/curriculum"
	"github.com/pradigi/backend/internal/database"
	"github.com/pradigi/backend/internal/middleware"
	applogger "github.com/pradigi/backend/internal/pkg/logger"
	"github.com/pradigi/backend/internal/router"
	"github.com/pradigi/backend/internal/sandbox"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	applogger.Init(cfg.Environment)
	logger := applogger.Get()

	db, err := database.NewPostgres(cfg.DatabaseURL)
	if err != nil {
		logger.Fatal().Err(err).Msg("failed to connect to database")
		return
	}
	defer db.Close()

	_, err = db.Exec("UPDATE schema_migrations SET dirty = false")
	if err != nil {
		logger.Warn().Err(err).Msg("failed to clean dirty schema_migrations")
	}

	logger.Info().Msg("connected to postgresql")

	var rdb *redis.Client
	if cfg.RedisURL != "" {
		rdb, err = database.NewRedis(cfg.RedisURL)
		if err != nil {
			logger.Warn().Err(err).Msg("failed to connect to redis, continuing without cache")
		} else {
			defer rdb.Close()
			logger.Info().Msg("connected to redis")
		}
	}

	if err := database.RunMigrations(cfg.DatabaseURL, "migrations"); err != nil {
		logger.Warn().Err(err).Msg("database migrations incomplete")
	} else {
		logger.Info().Msg("database migrations up to date")
	}

	var pool sandbox.RunnerPool
	var asynqClient *asynq.Client
	redisOpt, err := asynq.ParseRedisURI(cfg.RedisURL)
	if err == nil {
		asynqClient = asynq.NewClient(redisOpt)

		poolConfig := sandbox.PoolConfig{
			MinIdle:        3,
			MaxPool:        20,
			MaxUse:         100,
			MaxLifetime:    1 * time.Hour,
			AcquireTimeout: 5 * time.Second,
		}
		pool = sandbox.NewWarmPool(context.Background(), poolConfig)
	} else {
		logger.Warn().Err(err).Msg("failed to parse redis url for asynq client")
	}

	var curator *curriculum.Worker
	if cfg.DeepSeekAPIKey != "" {
		curator = curriculum.NewWorker(db, cfg.DeepSeekAPIKey, cfg.DeepSeekModel, logger)
		go curator.Start(context.Background())
		logger.Info().Msg("curriculum worker started")
	}

	r := router.New(cfg, db, rdb, pool, asynqClient)

	if curator != nil {
		r.POST("/api/v1/admin/curriculum/trigger", middleware.Auth(cfg.JWTSecret), func(c *gin.Context) {
			if !c.GetBool("is_superuser") {
				c.JSON(http.StatusForbidden, gin.H{"error": "admin access required", "success": false})
				return
			}
			c.JSON(http.StatusOK, gin.H{"status": "running", "message": "curriculum cycle triggered"})
			go func() {
				if err := curator.RunCycle(context.Background()); err != nil {
					logger.Error().Err(err).Msg("manual curriculum cycle failed")
				}
			}()
		})
	}

	addr := ":" + cfg.Port
	srv := &http.Server{
		Addr:    addr,
		Handler: r,
	}

	go func() {
		logger.Info().Str("addr", addr).Msg("starting server")
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Fatal().Err(err).Msg("server failed to start")
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	logger.Info().Msg("Shutting down server...")

	// The context is used to inform the server it has 5 seconds to finish
	// the request it is currently handling
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Fatal().Err(err).Msg("Server forced to shutdown")
	}

	logger.Info().Msg("Server exiting")
	if asynqClient != nil {
		asynqClient.Close()
	}
}
