package admin

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	svc *Service
}

func NewHandler(svc *Service) *Handler {
	return &Handler{svc: svc}
}

func requireSuperuser(c *gin.Context) bool {
	isSuperuser := c.GetBool("is_superuser")
	if !isSuperuser {
		c.JSON(http.StatusForbidden, gin.H{"error": "admin access required", "success": false})
		return false
	}
	return true
}

func (h *Handler) ListUsers(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}
	users, err := h.svc.ListUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": users})
}

func (h *Handler) UpdateUser(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}

	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id", "success": false})
		return
	}

	var req UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	if err := h.svc.UpdateUser(id, req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "User updated"})
}

func (h *Handler) CreateSection(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}

	var req CreateSectionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	if err := h.svc.CreateSection(req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Section created"})
}

func (h *Handler) CreateModule(c *gin.Context) {
	if !requireSuperuser(c) {
		return
	}

	var req CreateModuleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	if err := h.svc.CreateModule(req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Module created"})
}
