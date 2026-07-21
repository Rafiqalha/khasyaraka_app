package middleware

import (
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
	
	httputil "github.com/pradigi/backend/internal/pkg/http"
)

type rateLimiter struct {
	limiters map[string]*rate.Limiter
	mu       sync.Mutex
	rate     rate.Limit
	burst    int
}

func newRateLimiter(r rate.Limit, b int) *rateLimiter {
	return &rateLimiter{
		limiters: make(map[string]*rate.Limiter),
		rate:     r,
		burst:    b,
	}
}

func (rl *rateLimiter) getLimiter(ip string) *rate.Limiter {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	limiter, exists := rl.limiters[ip]
	if !exists {
		limiter = rate.NewLimiter(rl.rate, rl.burst)
		rl.limiters[ip] = limiter
	}

	return limiter
}

// RateLimit creates an in-memory rate limiter based on client IP.
func RateLimit(requestsPerSecond float64, burst int) gin.HandlerFunc {
	limiter := newRateLimiter(rate.Limit(requestsPerSecond), burst)

	// Background cleanup of old limiters is omitted for brevity in MVP
	// For production readiness without Redis, we'd add an eviction mechanism.

	return func(c *gin.Context) {
		ip := c.ClientIP()
		l := limiter.getLimiter(ip)

		if !l.Allow() {
			c.JSON(http.StatusTooManyRequests, httputil.APIResponse{
				Success: false,
				Error: &httputil.ErrorDetail{
					Code:    httputil.CodeTooManyRequests,
					Message: "Too many requests. Please try again later.",
				},
			})
			c.Abort()
			return
		}
		c.Next()
	}
}
