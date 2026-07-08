package main

import (
	"log"
	"os"

	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog"

	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/database"
	"github.com/pradigi/backend/internal/router"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	logger := zerolog.New(os.Stderr).With().Timestamp().Logger()
	if cfg.IsProduction() {
		logger = logger.Level(zerolog.InfoLevel)
	} else {
		logger = logger.Level(zerolog.DebugLevel)
	}

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

	r := router.New(cfg, db, rdb, logger)

	addr := ":" + cfg.Port
	logger.Info().Str("addr", addr).Msg("starting server")

	if err := r.Run(addr); err != nil {
		logger.Fatal().Err(err).Msg("server failed to start")
	}
}
