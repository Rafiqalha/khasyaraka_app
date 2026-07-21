package callbacks

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog"

	"github.com/pradigi/backend/internal/legacy/hearts"
)

// Handler holds callback HTTP handlers.
type Handler struct {
	heartsSvc   *hearts.Service
	rdb         *redis.Client
	logger      zerolog.Logger
	environment string
}

// NewHandler creates a new callback handler.
func NewHandler(heartsSvc *hearts.Service, rdb *redis.Client, logger zerolog.Logger, env string) *Handler {
	return &Handler{
		heartsSvc:   heartsSvc,
		rdb:         rdb,
		logger:      logger,
		environment: env,
	}
}

// AdMobSSV handles AdMob Server-Side Verification callbacks.
// URL: GET /api/v1/callbacks/admob?ad_network=...&custom_data={user_id}&signature=...&key_id=...
func (h *Handler) AdMobSSV(c *gin.Context) {
	// 1. Verify signature
	rawQuery := c.Request.URL.RawQuery
	err := VerifyAdMobSSV([]byte(rawQuery))
	if err != nil {
		h.logger.Warn().Err(err).Msg("AdMob SSV verification failed")
		if h.environment == "production" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid AdMob SSV signature"})
			return
		}
		// In development, log warning but continue
		h.logger.Warn().Msg("DEV MODE: continuing despite SSV failure")
	} else {
		h.logger.Info().Msg("AdMob SSV verification passed")
	}

	// 2. Extract user ID and transaction ID
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		userIDStr = c.Query("custom_data")
	}
	transactionID := c.Query("transaction_id")
	if transactionID == "" {
		transactionID = c.Query("ad_network_transaction_id")
	}
	if transactionID == "" {
		transactionID = c.Query("signature")
	}
	rewardItem := c.Query("reward_item")

	if userIDStr == "" {
		h.logger.Warn().Msg("AdMob callback without user_id/custom_data")
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing user_id"})
		return
	}
	if transactionID == "" {
		h.logger.Warn().Msg("AdMob callback without transaction ID")
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing transaction_id"})
		return
	}

	// 3. Strict reward type check in production
	if rewardItem != "hearts" && h.environment == "production" {
		h.logger.Warn().Str("reward_item", rewardItem).Msg("rejected unexpected reward type")
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("unexpected reward type: %s", rewardItem)})
		return
	}

	userID, err := strconv.ParseInt(userIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user_id"})
		return
	}

	// 4. Anti-replay check (idempotency via Redis SETNX)
	if h.rdb != nil {
		txKey := fmt.Sprintf("admob:tx:%s", transactionID)
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		// SETNX: only set if not exists, TTL 24h
		set, err := h.rdb.SetNX(ctx, txKey, "1", 24*time.Hour).Result()
		if err != nil {
			h.logger.Error().Err(err).Msg("Redis SETNX error for anti-replay")
			// Continue anyway — don't block reward on Redis failure
		} else if !set {
			// Already processed
			h.logger.Info().Str("tx", transactionID).Msg("transaction already processed")
			c.JSON(http.StatusOK, gin.H{"status": "ok", "message": "already processed"})
			return
		}
	}

	// 5. Reward user — increment hearts (atomic, cap at 5)
	h.logger.Info().Int64("user_id", userID).Str("tx", transactionID).Msg("rewarding user")
	newHearts, err := h.heartsSvc.IncrementHearts(userID, 1)
	if err != nil {
		h.logger.Error().Err(err).Int64("user_id", userID).Msg("failed to increment hearts")
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal server error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "ok", "hearts": newHearts})
}
