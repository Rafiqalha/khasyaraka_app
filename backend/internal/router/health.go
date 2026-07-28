package router

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
)

type healthResponse struct {
	Status      string `json:"status"`
	Environment string `json:"environment"`
	Database    string `json:"database"`
	Redis       string `json:"redis"`
}

func healthHandler(db *sqlx.DB, rdb *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		dbStatus := "disconnected"
		if err := db.Ping(); err == nil {
			dbStatus = "connected"
		}

		redisStatus := "disconnected"
		if rdb != nil {
			if _, err := rdb.Ping(c.Request.Context()).Result(); err == nil {
				redisStatus = "connected"
			}
		}

		overallStatus := "healthy"
		if dbStatus != "connected" || (rdb != nil && redisStatus != "connected") {
			overallStatus = "degraded"
		}

		c.JSON(http.StatusOK, healthResponse{
			Status:      overallStatus,
			Environment: gin.Mode(),
			Database:    dbStatus,
			Redis:       redisStatus,
		})
	}
}
