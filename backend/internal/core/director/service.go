package director

import (
	"context"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	"github.com/pradigi/backend/internal/core/llm"
	"github.com/pradigi/backend/internal/pkg/logger"
	"github.com/redis/go-redis/v9"
)

type InsightJSON struct {
	Observation string `json:"observation"`
	Motivation  string `json:"motivation"`
	Strategy    string `json:"strategy"`
	Reflection  string `json:"reflection"`
}

type Service struct {
	db  *sqlx.DB
	rdb *redis.Client
	ai  llm.Client
}

func NewService(db *sqlx.DB, rdb *redis.Client, ai llm.Client) *Service {
	return &Service{
		db:  db,
		rdb: rdb,
		ai:  ai,
	}
}

func (s *Service) GenerateInsight(ctx context.Context, userID string) error {
	// 1. Fetch director_snapshot from Redis
	snapshotKey := fmt.Sprintf("director_snapshot:%s", userID)
	snapshotJSON, err := s.rdb.Get(ctx, snapshotKey).Result()
	if err != nil {
		if err == redis.Nil {
			logger.Error().Str("user", userID).Msg("No snapshot found for director")
			return nil // Nothing to do if no snapshot
		}
		return fmt.Errorf("fetch snapshot: %w", err)
	}

	systemPrompt := `You are Pradigi AI Director. You oversee the user's learning based on their latest Knowledge Snapshot.
You MUST output strictly in JSON format matching this schema:
{
  "observation": "What do you observe from their recent performance or current state?",
  "motivation": "A brief, encouraging coaching tip.",
  "strategy": "A high-level strategy recommendation based on their trajectory.",
  "reflection": "A thoughtful question to make them reflect on their learning."
}`

	userPrompt := fmt.Sprintf("User Knowledge Snapshot:\n%s", snapshotJSON)

	start := time.Now()
	// 3. Call AI
	jsonStr, tokensIn, tokensOut, err := s.ai.GenerateJSON(ctx, systemPrompt, userPrompt)
	latency := time.Since(start).Milliseconds()

	if err != nil {
		logger.Error().Err(err).Msg("AI generation failed")
		return err
	}

	// Log telemetry
	_, _ = s.db.ExecContext(ctx, `
		INSERT INTO ai_telemetry (user_id, provider, model_version, tokens_in, tokens_out, latency_ms)
		VALUES ($1, $2, $3, $4, $5, $6)`,
		userID, "deepseek", "deepseek-v4-flash", tokensIn, tokensOut, latency,
	)

	// 4. Cache Insight in Redis
	cacheKey := fmt.Sprintf("director:insight:%s", userID)
	err = s.rdb.Set(ctx, cacheKey, jsonStr, 15*time.Minute).Err()
	if err != nil {
		return fmt.Errorf("cache insight: %w", err)
	}

	// 5. Fire Pub/Sub for SSE
	pubsubKey := fmt.Sprintf("director:finished:%s", userID)
	s.rdb.Publish(ctx, pubsubKey, jsonStr)

	logger.Info().Str("user", userID).Int64("latency_ms", latency).Msg("AI Insight generated successfully")
	return nil
}
