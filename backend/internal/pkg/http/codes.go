package http

type Code string

const (
	CodeSuccess         Code = "SUCCESS"
	CodeCreated         Code = "CREATED"
	CodeNoContent       Code = "NO_CONTENT"
	CodeInvalidRequest  Code = "INVALID_REQUEST"
	CodeUnauthorized    Code = "UNAUTHORIZED"
	CodeForbidden       Code = "FORBIDDEN"
	CodeNotFound        Code = "NOT_FOUND"
	CodeConflict        Code = "CONFLICT"
	CodeInternalError   Code = "INTERNAL_ERROR"
	CodeTooManyRequests Code = "TOO_MANY_REQUESTS"
)
