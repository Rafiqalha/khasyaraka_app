package middleware

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
)

// RateLimiter enforces a maximum number of requests per window for a specific UserID.
func RateLimiter(rdb *redis.Client, maxRequests int, window time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		if rdb == nil {
			c.Next()
			return
		}

		userID := c.GetString("user_id")
		if userID == "" {
			userID = c.GetString("userId")
		}

		var key string
		if userID != "" {
			key = fmt.Sprintf("ratelimit:user:%s:path:%s", userID, c.FullPath())
		} else {
			key = fmt.Sprintf("ratelimit:ip:%s:path:%s", c.ClientIP(), c.FullPath())
		}

		ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
		defer cancel()

		count, err := rdb.Incr(ctx, key).Result()
		if err != nil {
			// Fail open on Redis errors
			c.Next()
			return
		}

		if count == 1 {
			rdb.Expire(ctx, key, window)
		}

		if int(count) > maxRequests {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"error": "Rate limit exceeded. Please try again later.",
			})
			return
		}

		c.Next()
	}
}
