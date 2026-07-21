package config

import (
	"fmt"
	"os"

	"github.com/spf13/viper"
)

type Config struct {
	// Server
	Port        string `mapstructure:"port"`
	Environment string `mapstructure:"environment"`

	// Database
	DatabaseURL string `mapstructure:"database_url"`
	RedisURL    string `mapstructure:"redis_url"`

	// JWT
	JWTSecret             string `mapstructure:"jwt_secret"`
	AccessTokenExpireMins int    `mapstructure:"access_token_expire_minutes"`

	// Google OAuth
	GoogleClientID string `mapstructure:"google_client_id"`

	// CORS
	CORSOrigins []string `mapstructure:"cors_origins"`

	// AI
	GeminiAPIKey      string  `mapstructure:"gemini_api_key"`
	GeminiModel       string  `mapstructure:"gemini_model"`
	AIMaxOutputTokens int     `mapstructure:"ai_max_output_tokens"`
	AITemperature     float64 `mapstructure:"ai_temperature"`
	DeepSeekAPIKey    string  `mapstructure:"deepseek_api_key"`
	DeepSeekModel     string  `mapstructure:"deepseek_model"`
}

func Load() (*Config, error) {
	env := os.Getenv("APP_ENV")
	if env == "" {
		env = "development"
	}

	v := viper.New()
	v.SetConfigName(env)
	v.SetConfigType("yaml")
	v.AddConfigPath("./config") // Relative to project root
	v.AddConfigPath("../config") // For tests

	v.AutomaticEnv() // Still allow environment variables to override

	if err := v.ReadInConfig(); err != nil {
		// It's okay if config file isn't found during some tests, we can fallback to env vars
		fmt.Printf("Warning: error reading config file: %v\n", err)
	}

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, fmt.Errorf("unmarshal config: %w", err)
	}

	// Environment variable overrides for sensitive data
	if jwtSecret := os.Getenv("JWT_SECRET"); jwtSecret != "" {
		cfg.JWTSecret = jwtSecret
	}
	if dbURL := os.Getenv("DATABASE_URL"); dbURL != "" {
		cfg.DatabaseURL = dbURL
	}
	if geminiKey := os.Getenv("GEMINI_API_KEY"); geminiKey != "" {
		cfg.GeminiAPIKey = geminiKey
	}
	if deepseekKey := os.Getenv("DEEPSEEK_API_KEY"); deepseekKey != "" {
		cfg.DeepSeekAPIKey = deepseekKey
	}

	// Set defaults if empty
	if cfg.Port == "" {
		cfg.Port = "8080"
	}
	if cfg.Environment == "" {
		cfg.Environment = env
	}

	return &cfg, nil
}

func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}
