package http

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

type ErrorDetail struct {
	Code    Code        `json:"code"`
	Message string      `json:"message"`
	Details interface{} `json:"details,omitempty"`
}

type APIResponse struct {
	Success bool         `json:"success"`
	Data    interface{}  `json:"data,omitempty"`
	Error   *ErrorDetail `json:"error,omitempty"`
}

func Success(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, APIResponse{
		Success: true,
		Data:    data,
	})
}

func Created(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, APIResponse{
		Success: true,
		Data:    data,
	})
}

func NoContent(c *gin.Context) {
	c.Status(http.StatusNoContent)
}

func BadRequest(c *gin.Context, code Code, message string) {
	c.JSON(http.StatusBadRequest, APIResponse{
		Success: false,
		Error: &ErrorDetail{
			Code:    code,
			Message: message,
		},
	})
}

func Unauthorized(c *gin.Context) {
	c.JSON(http.StatusUnauthorized, APIResponse{
		Success: false,
		Error: &ErrorDetail{
			Code:    CodeUnauthorized,
			Message: "Unauthorized access",
		},
	})
}

func Forbidden(c *gin.Context) {
	c.JSON(http.StatusForbidden, APIResponse{
		Success: false,
		Error: &ErrorDetail{
			Code:    CodeForbidden,
			Message: "Access forbidden",
		},
	})
}

func NotFound(c *gin.Context, message string) {
	c.JSON(http.StatusNotFound, APIResponse{
		Success: false,
		Error: &ErrorDetail{
			Code:    CodeNotFound,
			Message: message,
		},
	})
}

func Conflict(c *gin.Context, message string) {
	c.JSON(http.StatusConflict, APIResponse{
		Success: false,
		Error: &ErrorDetail{
			Code:    CodeConflict,
			Message: message,
		},
	})
}

func Internal(c *gin.Context, message string) {
	c.JSON(http.StatusInternalServerError, APIResponse{
		Success: false,
		Error: &ErrorDetail{
			Code:    CodeInternalError,
			Message: message,
		},
	})
}
