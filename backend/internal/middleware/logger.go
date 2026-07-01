package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog"
)

func Logger(logger zerolog.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path

		c.Next()

		latency := time.Since(start)
		status := c.Writer.Status()
		method := c.Request.Method

		var ev *zerolog.Event
		if status >= 500 {
			ev = logger.Error()
		} else if status >= 400 {
			ev = logger.Warn()
		} else {
			ev = logger.Info()
		}

		ev.
			Str("method", method).
			Str("path", path).
			Int("status", status).
			Dur("latency", latency).
			Int("size", c.Writer.Size()).
			Msg("request")
	}
}
