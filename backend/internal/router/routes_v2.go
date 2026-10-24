package router

import (
	"log"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/hibiken/asynq"
	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"

	"github.com/pradigi/backend/internal/academy"
	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/core/catalog"
	corecompiler "github.com/pradigi/backend/internal/core/compiler"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/journey"
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/core/llm/deepseek"
	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/core/mission_engine"
	"github.com/pradigi/backend/internal/core/pack"
	"github.com/pradigi/backend/internal/core/planner"
	"github.com/pradigi/backend/internal/core/resolver"
	"github.com/pradigi/backend/internal/core/runtime"
	"github.com/pradigi/backend/internal/core/services"
	"github.com/pradigi/backend/internal/middleware"
	"github.com/pradigi/backend/internal/sandbox"
)

// registerV2Routes initializes and registers all G2 Learning OS (v2) endpoints.
func registerV2Routes(
	r *gin.Engine,
	cfg *config.Config,
	db *sqlx.DB,
	rdb *redis.Client,
	pool sandbox.RunnerPool,
	asynqClient *asynq.Client,
) {
	v2 := r.Group("/api/v2")

	academiesDir := "academies"
	if _, err := os.Stat(filepath.Join("academies", "ai_academy")); os.IsNotExist(err) {
		if _, err := os.Stat(filepath.Join("..", "academies", "ai_academy")); err == nil {
			academiesDir = "../academies"
		}
	}

	packRuntime := runtime.NewMemoryPackRuntime()
	runtimeRepo := runtime.NewRepository(db)
	runtimeManager := runtime.NewManager(runtimeRepo, packRuntime)

	bus := events.NewBus(db, asynqClient)
	aiClient := deepseek.NewAdapter(cfg.DeepSeekAPIKey, cfg.DeepSeekModel)

	packRegistry := pack.NewLocalRegistry(academiesDir)
	packLoader := pack.NewFilesystemLoader()
	missionPlanner := planner.NewAdaptivePlanner()
	contextBuilder := mission_engine.NewDefaultContextBuilder()
	engine := mission_engine.NewEngine(aiClient)
	compiler := mission_compiler.NewCompiler()

	contentRegistry := catalog.NewContentRegistry(academiesDir)
	if err := contentRegistry.Load(); err != nil {
		log.Printf("[WARN] ContentRegistry load warning: %v", err)
	}

	blueprintRegistry := catalog.NewBlueprintRegistry(academiesDir)
	if err := blueprintRegistry.Load(); err != nil {
		log.Printf("[WARN] BlueprintRegistry load warning: %v", err)
	} else {
		log.Printf("✅ [BLUEPRINT_REGISTRY] Loaded %d academies from filesystem", len(blueprintRegistry.GetAcademies()))
	}

	artifactStore := corecompiler.NewCompiledArtifactStore()
	_ = corecompiler.NewCompiler(artifactStore)

	catalogRepo := catalog.NewRepository(db)
	catalogLoader := catalog.NewMetadataLoader()
	catalogSvc := catalog.NewService(catalogRepo, catalogLoader, "catalog")
	journeySvc := journey.NewService(catalogRepo, packRegistry, packLoader, missionPlanner, contextBuilder, engine)
	catalogH := catalog.NewHandler(catalogSvc, journeySvc)
	osResolver := resolver.NewResolver(catalogRepo, blueprintRegistry)

	academyRepo := academy.NewRepository(db)
	academyH := academy.NewHandler(academyRepo, runtimeManager, bus, rdb, osResolver)

	// OS Command Center Routes
	osGrp := v2.Group("/os")
	osGrp.Use(middleware.Auth(cfg.JWTSecret))
	{
		osGrp.GET("/home", academyH.GetHome)
		osGrp.GET("/stream", academyH.StreamUpdates)
		osGrp.GET("/registry", academyH.GetOSRegistry)
		osGrp.GET("/portfolio", academyH.GetOSPortfolio)
		osGrp.GET("/profile", academyH.GetOSProfile)

		kernelRegistry := kernel.NewRegistry()
		kernelRegistry.Register(services.NewSandboxService(pool))
		kernelRegistry.Register(services.NewAIService())
		kernelRegistry.Register(services.NewKnowledgeService())
		kernelRegistry.Register(services.NewFileService())
		kernelRegistry.Register(services.NewNotebookService())

		runtimeAPI := runtime.NewAPIHandler(
			packRegistry,
			packLoader,
			missionPlanner,
			contextBuilder,
			engine,
			compiler,
			kernelRegistry,
			bus,
			runtimeManager,
		)
		osGrp.POST("/mission/start", runtimeAPI.StartMission)
	}

	// Profile Provisioning Routes
	profileGrp := v2.Group("/profile")
	profileGrp.Use(middleware.Auth(cfg.JWTSecret))
	{
		profileGrp.POST("/initialize", academyH.InitializeProfile)
		profileGrp.GET("/provision-stream", academyH.ProvisionStream)
	}

	// Academies Metadata Routes
	acadGrp := v2.Group("/academies")
	{
		acadGrp.GET("", academyH.GetAcademies)
		acadGrp.GET("/:id/tree", academyH.GetAcademyTree)
		acadGrp.GET("/:id/specializations", academyH.GetSpecializations)
	}

	// Catalog & Intent Discovery Routes
	catGrp := v2.Group("/catalog")
	{
		catGrp.GET("/academies", catalogH.GetAcademies)
		catGrp.GET("/academies/:academy_id/specializations", catalogH.GetSpecializations)
		catGrp.GET("/experiences", catalogH.GetExperiences)
		catGrp.GET("/execution-intents", catalogH.GetExecutionIntents)

		authCatGrp := catGrp.Group("")
		authCatGrp.Use(middleware.Auth(cfg.JWTSecret))
		{
			authCatGrp.POST("/journeys/initialize", catalogH.InitializeJourney)
		}
	}

	// Pack SDK Routes
	packH := pack.NewHandler(packRegistry, packLoader)
	packGrp := v2.Group("/packs")
	{
		packH.RegisterRoutes(packGrp)
	}

	// Runtime Lifecycle Routes
	runtimeH := runtime.NewHandler(runtimeManager, bus)
	runtimeGrp := v2.Group("/runtime")
	runtimeGrp.Use(middleware.Auth(cfg.JWTSecret))
	{
		runtimeGrp.POST("/start", runtimeH.StartSession)
		runtimeGrp.GET("/current", runtimeH.GetCurrent)
		runtimeGrp.POST("/events", runtimeH.HandleEvent)
		runtimeGrp.GET("/node/:id", runtimeH.GetNode)
	}
}
