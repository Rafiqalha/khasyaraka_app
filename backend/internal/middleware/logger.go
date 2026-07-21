package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	applogger "github.com/pradigi/backend/internal/pkg/logger"
)

func Logger() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		
		// Set a default empty request ID if middleware not used
		reqID, _ := c.Get(RequestIDKey)
		if reqID == nil {
			reqID = ""
		}

		c.Next()

		latency := time.Since(start)
		status := c.Writer.Status()
		method := c.Request.Method
		path := c.Request.URL.Path
		ip := c.ClientIP()

		userID, _ := c.Get("user_id")
		if userID == nil {
			userID = ""
		}

		var ev = applogger.Info()
		if status >= 500 {
			ev = applogger.Error()
		}

		ev.
			Str("request_id", reqID.(string)).
			Str("user_id", userID.(string)).
			Str("route", method+" "+path).
			Str("latency", latency.String()).
			Int("status", status).
			Str("ip", ip).
			Msg("api_request")
	}
}
