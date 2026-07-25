package middleware

import (
	"fmt"
	"net/http"
	"runtime/debug"

	"github.com/gin-gonic/gin"
	applogger "github.com/pradigi/backend/internal/pkg/logger"
)

func Recovery() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if err := recover(); err != nil {
				reqID, _ := c.Get(RequestIDKey)
				if reqID == nil {
					reqID = ""
				}

				userID, _ := c.Get("user_id")
				if userID == nil {
					userID = ""
				}

				stackTrace := string(debug.Stack())

				applogger.Error().
					Str("request_id", fmt.Sprintf("%v", reqID)).
					Str("user_id", fmt.Sprintf("%v", userID)).
					Str("method", c.Request.Method).
					Str("path", c.Request.URL.Path).
					Str("ip", c.ClientIP()).
					Interface("panic_error", err).
					Str("stack", stackTrace).
					Msg("panic_recovered")

				c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
					"error": "internal server error",
				})
			}
		}()
		c.Next()
	}
}

