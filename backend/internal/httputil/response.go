package httputil

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// SuccessResponse is the standard API success envelope.
type SuccessResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Message string      `json:"message,omitempty"`
}

// ErrorDetail holds structured error info.
type ErrorDetail struct {
	Code    string      `json:"code"`
	Message string      `json:"message"`
	Details interface{} `json:"details,omitempty"`
}

// ErrorResponse is the standard API error envelope.
type ErrorResponse struct {
	Success bool        `json:"success"`
	Error   ErrorDetail `json:"error"`
}

// Success writes a standard JSON success response.
func Success(c *gin.Context, data interface{}, message string) {
	c.JSON(http.StatusOK, SuccessResponse{
		Success: true,
		Data:    data,
		Message: message,
	})
}

// SuccessWithStatus writes a success response with a custom HTTP status.
func SuccessWithStatus(c *gin.Context, status int, data interface{}, message string) {
	c.JSON(status, SuccessResponse{
		Success: true,
		Data:    data,
		Message: message,
	})
}

// Error writes a standard JSON error response.
func Error(c *gin.Context, status int, code string, message string) {
	c.JSON(status, ErrorResponse{
		Success: false,
		Error: ErrorDetail{
			Code:    code,
			Message: message,
		},
	})
}

// ErrorWithDetails writes an error response with extra detail payload.
func ErrorWithDetails(c *gin.Context, status int, code, message string, details interface{}) {
	c.JSON(status, ErrorResponse{
		Success: false,
		Error: ErrorDetail{
			Code:    code,
			Message: message,
			Details: details,
		},
	})
}

// BadRequest is a shorthand for 400 errors.
func BadRequest(c *gin.Context, message string) {
	Error(c, http.StatusBadRequest, "BAD_REQUEST", message)
}

// Unauthorized is a shorthand for 401 errors.
func Unauthorized(c *gin.Context, message string) {
	Error(c, http.StatusUnauthorized, "UNAUTHORIZED", message)
}

// Forbidden is a shorthand for 403 errors.
func Forbidden(c *gin.Context, message string) {
	Error(c, http.StatusForbidden, "FORBIDDEN", message)
}

// NotFound is a shorthand for 404 errors.
func NotFound(c *gin.Context, message string) {
	Error(c, http.StatusNotFound, "NOT_FOUND", message)
}

// InternalError is a shorthand for 500 errors.
// In production the raw message should be replaced with a generic one.
func InternalError(c *gin.Context, message string) {
	Error(c, http.StatusInternalServerError, "INTERNAL_SERVER_ERROR", message)
}
