package config

import (
	"fmt"
	"os"

	"github.com/spf13/viper"
)

type Config struct {
	// Server
	Port        string `mapstructure:"PORT"`
	Environment string `mapstructure:"ENVIRONMENT"`

	// Database
	DatabaseURL string `mapstructure:"DATABASE_URL"`

	// Redis
	RedisURL string `mapstructure:"REDIS_URL"`

	// JWT
	JWTSecret              string `mapstructure:"JWT_SECRET"`
	AccessTokenExpireMins  int    `mapstructure:"ACCESS_TOKEN_EXPIRE_MINUTES"`

	// Google OAuth
	GoogleClientID string `mapstructure:"GOOGLE_CLIENT_ID"`

	// ImageKit
	ImageKitPrivateKey  string `mapstructure:"IMAGEKIT_PRIVATE_KEY"`
	ImageKitPublicKey   string `mapstructure:"IMAGEKIT_PUBLIC_KEY"`
	ImageKitURL         string `mapstructure:"IMAGEKIT_URL_ENDPOINT"`

	// CORS
	CORSOrigins []string `mapstructure:"CORS_ORIGINS"`
}

func Load() (*Config, error) {
	v := viper.New()

	v.SetDefault("PORT", "8080")
	v.SetDefault("ENVIRONMENT", "development")
	v.SetDefault("DATABASE_URL", "postgres://scout_admin:scout_password_local@localhost:5433/scout_os?sslmode=disable")
	v.SetDefault("REDIS_URL", "redis://localhost:6379/0")
	v.SetDefault("ACCESS_TOKEN_EXPIRE_MINUTES", 10080)
	v.SetDefault("CORS_ORIGINS", []string{"*"})

	v.AutomaticEnv()

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, fmt.Errorf("unmarshal config: %w", err)
	}

	if cfg.JWTSecret == "" {
		cfg.JWTSecret = os.Getenv("JWT_SECRET")
	}
	if cfg.GoogleClientID == "" {
		cfg.GoogleClientID = os.Getenv("GOOGLE_CLIENT_ID")
	}

	return &cfg, nil
}

func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}
