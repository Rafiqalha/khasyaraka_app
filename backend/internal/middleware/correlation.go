package middleware

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func CorrelationID() gin.HandlerFunc {
	return func(c *gin.Context) {
		corrID := c.GetHeader("X-Correlation-ID")
		if corrID == "" {
			corrID = uuid.NewString()
		}
		c.Set("correlation_id", corrID)
		c.Header("X-Correlation-ID", corrID)
		c.Next()
	}
}
