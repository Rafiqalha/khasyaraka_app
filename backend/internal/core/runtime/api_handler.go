package runtime

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/core/mission_engine"
	"github.com/pradigi/backend/internal/core/pack"
	"github.com/pradigi/backend/internal/core/planner"
)

type APIHandler struct {
	registry       pack.Registry
	loader         pack.Loader
	planner        planner.Planner
	contextBuilder mission_engine.ContextBuilder
	engine         *mission_engine.Engine
	compiler       *mission_compiler.Compiler
	kernelRegistry kernel.KernelRegistry
	bus            kernel.EventBus
}

func NewAPIHandler(
	registry pack.Registry,
	loader pack.Loader,
	planr planner.Planner,
	contextBuilder mission_engine.ContextBuilder,
	engine *mission_engine.Engine,
	compiler *mission_compiler.Compiler,
	kernelRegistry kernel.KernelRegistry,
	bus kernel.EventBus,
) *APIHandler {
	return &APIHandler{
		registry:       registry,
		loader:         loader,
		planner:        planr,
		contextBuilder: contextBuilder,
		engine:         engine,
		compiler:       compiler,
		kernelRegistry: kernelRegistry,
		bus:            bus,
	}
}

type StartMissionRequest struct {
	AcademyID string `json:"academy_id"`
	PackID    string `json:"pack_id"`
}

// StartMission handles the POST /api/v2/os/mission/start endpoint.
func (h *APIHandler) StartMission(c *gin.Context) {
	var req StartMissionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		req.PackID = "backend_engineering" // Fallback temporarily if frontend doesn't send it yet
	}
	if req.PackID == "" {
		req.PackID = "backend_engineering"
	}

	sessionID := "sess_" + c.GetString("user_id") // Mock session ID generator

	// 1. Registry: Find Pack
	desc, err := h.registry.Get(req.PackID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pack not found"})
		return
	}

	// 2. Loader: Read Blueprint
	pkg, err := h.loader.Load(c.Request.Context(), desc)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load blueprint: " + err.Error()})
		return
	}

	// 3. Planner: Create Strategy
	snapshot := planner.CapabilitySnapshot{} // Mock empty snapshot for now
	plan, err := h.planner.Plan(c.Request.Context(), sessionID, pkg, snapshot)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Planner failed: " + err.Error()})
		return
	}

	// 4. Context Builder: Fetch RAG Knowledge
	mctx, err := h.contextBuilder.BuildContext(c.Request.Context(), plan, pkg.ReferencesPath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to build context: " + err.Error()})
		return
	}

	// 5. Mission Engine: Generate content with AI
	missionPkg, err := h.engine.Generate(c.Request.Context(), mctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate mission package: " + err.Error()})
		return
	}

	// 6. Compiler: Build Runtime Config
	bundle, err := h.compiler.Compile(missionPkg)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to compile mission bundle: " + err.Error()})
		return
	}

	// 7. Runtime: Initialize
	missionRuntime := NewMissionRuntime(plan.SessionID, h.bus, h.kernelRegistry)

	if err := missionRuntime.LoadBundle(c.Request.Context(), bundle); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load bundle into runtime: " + err.Error()})
		return
	}

	if err := missionRuntime.Start(c.Request.Context()); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start runtime: " + err.Error()})
		return
	}

	// 8. Return to UI
	c.JSON(http.StatusOK, gin.H{
		"status": "started",
		"bundle": bundle,
	})
}
