package workspace

import (
	"github.com/gin-gonic/gin"
	apphttp "github.com/pradigi/backend/internal/pkg/http"
)

type Handler struct {
	workspaceService WorkspaceService
	artifactService  ArtifactService
	snapshotService  SnapshotService
}

func NewHandler(ws WorkspaceService, arts ArtifactService, snaps SnapshotService) *Handler {
	return &Handler{
		workspaceService: ws,
		artifactService:  arts,
		snapshotService:  snaps,
	}
}

func (h *Handler) CreateWorkspace(c *gin.Context) {
	var req CreateWorkspaceCommand
	if err := c.ShouldBindJSON(&req); err != nil {
		apphttp.BadRequest(c, apphttp.CodeInvalidRequest, "Invalid request body")
		return
	}

	// Biasanya Get UserID/TenantID dari JWT Context. Untuk MVP:
	req.OwnerID = c.GetString("user_id")
	if req.OwnerID == "" {
		req.OwnerID = "anonymous"
	}
	req.OwnerType = OwnerUser

	w, err := h.workspaceService.CreateWorkspace(c.Request.Context(), req)
	if err != nil {
		apphttp.Internal(c, err.Error())
		return
	}

	apphttp.Created(c, w)
}
