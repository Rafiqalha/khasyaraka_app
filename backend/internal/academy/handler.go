package academy

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/resolver"
	"github.com/pradigi/backend/internal/core/runtime"
	"github.com/redis/go-redis/v9"
)

type Handler struct {
	repo    *Repository
	manager *runtime.Manager
	bus     *events.Bus
	rdb     *redis.Client
	res     resolver.Resolver
}

func NewHandler(repo *Repository, manager *runtime.Manager, bus *events.Bus, rdb *redis.Client, res resolver.Resolver) *Handler {
	return &Handler{
		repo:    repo,
		manager: manager,
		bus:     bus,
		rdb:     rdb,
		res:     res,
	}
}

// InitializeProfile saves the user's intent to a LearningProfile
func (h *Handler) InitializeProfile(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	var req InitializeProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Delegate resolution to the new OS Resolver pipeline
	resolution, err := h.res.Resolve(c.Request.Context(), resolver.IntentRequest{
		Version:         req.Version,
		Academy:         req.Intent.Academy,
		Specialization:  req.Intent.Specialization,
		Mission:         req.Intent.Mission,
		Experience:      req.Intent.Experience,
		ExecutionIntent: req.Intent.ExecutionIntent,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to resolve intent"})
		return
	}
	if resolution == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Goal Not Found"})
		return
	}

	profile := &LearningProfile{
		UserID:         userID,
		Goal:           req.Intent.Mission,
		Experience:     req.Intent.Experience,
		Endgame:        req.Intent.Specialization,
		LearningGoalID: resolution.GoalID,
	}

	if err := h.repo.CreateProfile(c.Request.Context(), profile); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save profile"})
		return
	}

	h.bus.Emit(c.Request.Context(), userID, nil, events.EventTypeProfileInitialized, profile)

	c.JSON(http.StatusOK, gin.H{"status": "success"})
}

// GetHome returns the OS Home data (Workspace/AI Command Center).
func (h *Handler) GetHome(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	profile, err := h.repo.GetProfile(c.Request.Context(), userID)
	if err != nil || profile == nil {
		c.JSON(http.StatusOK, HomeResponse{RequiresInitialization: true})
		return
	}

	// If there is an active runtime session, fetch the node info
	session, node, _ := h.manager.GetCurrentSession(c.Request.Context(), userID)

	if node != nil {
		// Used in older logic
	} else if session != nil {
		// Used in older logic
	}

	// Calculate deterministic state from Runtime Manager (mocked slightly for MVP, but sourced deterministically)
	masteredCount := 0
	h.repo.db.GetContext(c.Request.Context(), &masteredCount, "SELECT count(*) FROM runtime_events WHERE user_id = $1 AND event_type = 'NODE_COMPLETED'", userID)

	cacheKey := fmt.Sprintf("director:insight:%s", userID)
	insightBytes, err := h.rdb.Get(c.Request.Context(), cacheKey).Bytes()

	var directorInsight *DirectorInsight
	isCalculating := false

	if err == redis.Nil {
		isCalculating = true
		// Trigger an event so Asynq eventually picks it up
		h.bus.Emit(c.Request.Context(), userID, nil, events.EventTypeWorkspaceOpened, nil)
	} else if err == nil {
		var insight DirectorInsight
		if json.Unmarshal(insightBytes, &insight) == nil {
			directorInsight = &insight
		}
	}

	activeJourney, _ := h.repo.GetActiveJourney(c.Request.Context(), userID)

	requiresInit := activeJourney == nil

	var activeRuntime *ActiveRuntimeInfo
	if activeJourney != nil {
		activeRuntime = &ActiveRuntimeInfo{
			RuntimeID:         "rt_ml_01",
			Title:             activeJourney.Specialization,
			Status:            "RUNNING",
			CurrentObjective:  "Implement Gradient Descent",
			LastActivityText:  "18 minutes ago",
			EstimatedDuration: "1h 42m",
			UserDifficulty:    "Intermediate",
			DirectorBrief: &DirectorBrief{
				Yesterday:       "Matrix Multiplication & Forward Pass",
				Today:           "Implement Gradient Descent",
				Risk:            "High loss instability if learning rate is oversized",
				Focus:           "Vectorized partial derivatives",
				ExpectedOutcome: "Pass 5/5 validation test cases",
			},
		}
	}

	res := HomeResponse{
		RequiresInitialization: requiresInit,
		IsCalculating:          isCalculating,
		GoalTitle:              profile.Goal,
		CurrentNode:            "",
		MasteredCompetencies:   masteredCount,
		RemainingCompetencies:  14,
		CurrentUnderstanding:   []string{"Python", "Functions", "Objects"},
		MissingCompetencies:    []string{"HTTP", "REST", "Databases"},
		DirectorInsight:        directorInsight,
		ActiveRuntime:          activeRuntime,
		KnowledgeUpdateCount:   2,
	}

	if activeJourney != nil {
		res.ActiveJourney = activeJourney
	} else {
		res.ActiveJourney = &ActiveJourneyData{
			Specialization: "No Active Journey",
			CurrentMission: stringPtr("Begin your journey in the Catalog"),
		}
	}

	c.JSON(http.StatusOK, res)
}

func stringPtr(s string) *string {
	return &s
}

// GetAcademies returns a list of all academies.
func (h *Handler) GetAcademies(c *gin.Context) {
	academies, err := h.repo.GetAllAcademies(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch academies"})
		return
	}
	c.JSON(http.StatusOK, academies)
}

// GetAcademyTree returns the full metadata tree (Domains, Specializations, Journeys) for an Academy.
func (h *Handler) GetAcademyTree(c *gin.Context) {
	academyID := c.Param("id")
	if academyID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Academy ID is required"})
		return
	}

	tree, err := h.repo.GetAcademyTree(c.Request.Context(), academyID)
	if err != nil {
		if err == sql.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{"error": "Academy not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch academy tree"})
		return
	}

	c.JSON(http.StatusOK, tree)
}

// GetSpecializations returns a flat list of specializations for an Academy
func (h *Handler) GetSpecializations(c *gin.Context) {
	academyID := c.Param("id")
	if academyID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Academy ID is required"})
		return
	}

	specs, err := h.repo.GetAcademySpecializations(c.Request.Context(), academyID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch specializations"})
		return
	}

	if specs == nil {
		specs = []SpecializationTree{}
	}

	c.JSON(http.StatusOK, specs)
}

// ProvisionStream simulates the OS provisioning steps via SSE
func (h *Handler) ProvisionStream(c *gin.Context) {
	c.Writer.Header().Set("Content-Type", "text/event-stream")
	c.Writer.Header().Set("Cache-Control", "no-cache")
	c.Writer.Header().Set("Connection", "keep-alive")
	c.Writer.Header().Set("Transfer-Encoding", "chunked")

	// Flush header so client gets connected right away
	c.Writer.Flush()

	steps := []struct {
		Event string
		Data  string
	}{
		{"resolver.started", `{"message": "Initializing Runtime..."}`},
		{"resolver.completed", `{"message": "Knowledge Graph Loaded"}`},
		{"planner.started", `{"message": "Resolving Goal..."}`},
		{"planner.completed", `{"message": "Learning Path Built"}`},
		{"runtime.started", `{"message": "Planning First Mission..."}`},
		{"director.ready", `{"message": "Connecting AI Director..."}`},
		{"workspace.ready", `{"message": "Runtime Ready"}`},
	}

	for _, step := range steps {
		// Simulate processing time for each step
		time.Sleep(800 * time.Millisecond)

		// Send SSE event
		c.SSEvent(step.Event, step.Data)
		c.Writer.Flush()
	}
}
