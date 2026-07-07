package auth

import (
	"errors"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetUserIDFromContext(c *gin.Context) (int64, error) {
	val := c.GetString("user_id")
	if val == "" {
		return 0, errors.New("user id not found in context")
	}
	return strconv.ParseInt(val, 10, 64)
}
