package main

import (
	"context"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/curriculum"
	"github.com/pradigi/backend/internal/database"
	"github.com/pradigi/backend/internal/router"
	applogger "github.com/pradigi/backend/internal/pkg/logger"
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

	if cfg.DeepSeekAPIKey != "" {
		curator := curriculum.NewWorker(db, cfg.DeepSeekAPIKey, cfg.DeepSeekModel, logger)
		go curator.Start(context.Background())
		logger.Info().Msg("curriculum worker started")

		r := router.New(cfg, db, rdb)

		r.GET("/api/v1/admin/trigger-curriculum", func(c *gin.Context) {
			c.JSON(200, gin.H{"status": "running", "message": "curriculum cycle triggered"})
			go func() {
				if err := curator.RunCycle(context.Background()); err != nil {
					logger.Error().Err(err).Msg("manual curriculum cycle failed")
				}
			}()
		})

		addr := ":" + cfg.Port
		logger.Info().Str("addr", addr).Msg("starting server")

		if err := r.Run(addr); err != nil {
			logger.Fatal().Err(err).Msg("server failed to start")
		}
	} else {
		r := router.New(cfg, db, rdb)

		addr := ":" + cfg.Port
		logger.Info().Str("addr", addr).Msg("starting server")

		if err := r.Run(addr); err != nil {
			logger.Fatal().Err(err).Msg("server failed to start")
		}
	}
}
