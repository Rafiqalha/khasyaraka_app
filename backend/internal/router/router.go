package router

import (
	"log"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	applogger "github.com/pradigi/backend/internal/pkg/logger"
	"github.com/redis/go-redis/v9"

	"github.com/hibiken/asynq"
	"github.com/pradigi/backend/internal/academies/cyber/arena"
	"github.com/pradigi/backend/internal/academies/cyber/ctf"
	"github.com/pradigi/backend/internal/academies/cyber/cyber"
	"github.com/pradigi/backend/internal/academies/scout/sandi"
	"github.com/pradigi/backend/internal/academies/scout/sku"
	"github.com/pradigi/backend/internal/academies/scout/survival"
	"github.com/pradigi/backend/internal/academies/scout/tkk"
	"github.com/pradigi/backend/internal/academy"
	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/core/catalog"
	corecompiler "github.com/pradigi/backend/internal/core/compiler"
	"github.com/pradigi/backend/internal/core/events"
	"github.com/pradigi/backend/internal/core/health"
	"github.com/pradigi/backend/internal/core/journey"
	"github.com/pradigi/backend/internal/core/pack"
	"github.com/pradigi/backend/internal/core/passport"
	"github.com/pradigi/backend/internal/core/planner"
	"github.com/pradigi/backend/internal/core/resolver"
	"github.com/pradigi/backend/internal/core/runtime"
	"github.com/pradigi/backend/internal/core/telemetry"
	"github.com/pradigi/backend/internal/legacy/admin"
	"github.com/pradigi/backend/internal/legacy/ai"
	"github.com/pradigi/backend/internal/legacy/callbacks"
	"github.com/pradigi/backend/internal/legacy/chat"
	"github.com/pradigi/backend/internal/legacy/hearts"
	"github.com/pradigi/backend/internal/legacy/leaderboard"
	"github.com/pradigi/backend/internal/legacy/location"
	"github.com/pradigi/backend/internal/legacy/token"
	"github.com/pradigi/backend/internal/legacy/training"
	"github.com/pradigi/backend/internal/metrics"
	"github.com/pradigi/backend/internal/middleware"
	"github.com/pradigi/backend/internal/modules/auth"
	"github.com/pradigi/backend/internal/modules/subscription"
	"github.com/pradigi/backend/internal/modules/users"
	"github.com/pradigi/backend/internal/sandbox"
	"github.com/pradigi/backend/internal/studio"

	"github.com/pradigi/backend/internal/core/evidence_validator"
	"github.com/pradigi/backend/internal/core/kernel"
	"github.com/pradigi/backend/internal/core/llm/deepseek"
	"github.com/pradigi/backend/internal/core/mission_compiler"
	"github.com/pradigi/backend/internal/core/mission_engine"
	"github.com/pradigi/backend/internal/core/services"
	"github.com/pradigi/backend/internal/core/tutor"
)

func New(cfg *config.Config, db *sqlx.DB, rdb *redis.Client, pool sandbox.RunnerPool, asynqClient *asynq.Client) *gin.Engine {
	r := gin.New()
	if len(cfg.TrustedProxies) > 0 {
		_ = r.SetTrustedProxies(cfg.TrustedProxies)
	} else {
		_ = r.SetTrustedProxies(nil)
	}
	r.Use(middleware.Recovery())
	r.Use(middleware.SecurityHeaders())
	r.Use(middleware.CorrelationID())
	r.Use(middleware.CORS(cfg.CORSOrigins))
	r.Use(middleware.Logger())

	// Health Endpoints
	healthH := health.NewHandler(db, pool)
	r.GET("/live", healthH.Live)
	r.GET("/ready", healthH.Ready)
	r.GET("/health/details", healthH.Details)

	api := r.Group("/api/v1")

	api.GET("/health", healthHandler(db, rdb))

	telemetryRepo := telemetry.NewRepository(db)
	metricsH := metrics.NewHandler(db, telemetryRepo)
	api.POST("/metrics/events", metricsH.TrackEvent)
	api.POST("/telemetry/batch", metricsH.TrackEpisode) // Used by Scout OS App

	// API V2 (G2 Learning OS)
	v2 := r.Group("/api/v2")

	packRuntime := runtime.NewMemoryPackRuntime()
	runtimeRepo := runtime.NewRepository(db)
	runtimeManager := runtime.NewManager(runtimeRepo, packRuntime)

	bus := events.NewBus(db, asynqClient)

	aiClient := deepseek.NewAdapter(cfg.DeepSeekAPIKey, cfg.DeepSeekModel)
	academiesDir := "academies"
	if _, err := os.Stat(filepath.Join("academies", "ai_academy")); os.IsNotExist(err) {
		if _, err := os.Stat(filepath.Join("..", "academies", "ai_academy")); err == nil {
			academiesDir = "../academies"
		}
	}
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

	osGrp := v2.Group("/os")
	osGrp.Use(middleware.Auth(cfg.JWTSecret))
	{
		osGrp.GET("/home", academyH.GetHome)
		osGrp.GET("/stream", academyH.StreamUpdates)

		// Pipeline dependencies are now instantiated globally above

		kernelRegistry := kernel.NewRegistry()
		kernelRegistry.Register(services.NewSandboxService())
		kernelRegistry.Register(services.NewAIService())
		kernelRegistry.Register(services.NewKnowledgeService())
		kernelRegistry.Register(services.NewFileService())
		kernelRegistry.Register(services.NewNotebookService())

		runtimeAPI := runtime.NewAPIHandler(packRegistry, packLoader, missionPlanner, contextBuilder, engine, compiler, kernelRegistry, bus)
		osGrp.POST("/mission/start", runtimeAPI.StartMission)
	}

	profileGrp := v2.Group("/profile")
	profileGrp.Use(middleware.Auth(cfg.JWTSecret))
	{
		profileGrp.POST("/initialize", academyH.InitializeProfile)
		profileGrp.GET("/provision-stream", academyH.ProvisionStream)
	}

	acadGrp := v2.Group("/academies")
	{
		acadGrp.GET("", academyH.GetAcademies)
		acadGrp.GET("/:id/tree", academyH.GetAcademyTree)
		acadGrp.GET("/:id/specializations", academyH.GetSpecializations)
	}

	catGrp := v2.Group("/catalog")
	{
		catGrp.GET("/academies", catalogH.GetAcademies)
		catGrp.GET("/academies/:academy_id/specializations", catalogH.GetSpecializations)
		catGrp.GET("/experiences", catalogH.GetExperiences)
		catGrp.GET("/execution-intents", catalogH.GetExecutionIntents)

		// Requires auth
		authCatGrp := catGrp.Group("")
		authCatGrp.Use(middleware.Auth(cfg.JWTSecret))
		{
			authCatGrp.POST("/journeys/initialize", catalogH.InitializeJourney)
		}
	}

	runtimeH := runtime.NewHandler(runtimeManager, bus)
	runtimeGrp := v2.Group("/runtime")
	runtimeGrp.Use(middleware.Auth(cfg.JWTSecret))
	{
		runtimeGrp.POST("/start", runtimeH.StartSession)
		runtimeGrp.GET("/current", runtimeH.GetCurrent)
		runtimeGrp.POST("/events", runtimeH.HandleEvent)
		runtimeGrp.GET("/node/:id", runtimeH.GetNode)
	}

	authRepo := auth.NewRepository(db)
	authSvc := auth.NewService(authRepo, cfg.JWTSecret, cfg.AccessTokenExpireMins)
	authH := auth.NewHandler(authSvc)

	authGroup := api.Group("/auth")
	{
		authGroup.POST("/register", authH.Register)
		authGroup.POST("/login", authH.Login)
		authGroup.POST("/google", authH.GoogleSignIn)
	}

	// Auth routes that require authentication
	authProtected := api.Group("/auth")
	authProtected.Use(middleware.Auth(cfg.JWTSecret))
	{
		authProtected.POST("/change-password", authH.ChangePassword)
	}

	usersRepo := users.NewRepository(db)
	usersSvc := users.NewService(usersRepo)
	usersH := users.NewHandler(usersSvc)

	journeyH := journey.NewHandler(filepath.Dir(academiesDir))

	heartsSvc := hearts.NewService(db, rdb)
	heartsH := hearts.NewHandler(heartsSvc)

	callbacksH := callbacks.NewHandler(heartsSvc, rdb, applogger.Get(), cfg.Environment)

	me := api.Group("/me")
	me.Use(middleware.Auth(cfg.JWTSecret))
	{
		me.GET("", usersH.GetMe)
		me.PATCH("/profile", usersH.UpdateProfile)
		me.POST("/avatar", usersH.UpdateAvatar)
		me.GET("/hearts", heartsH.GetHearts)
		me.POST("/hearts/decrement", heartsH.Decrement)
	}

	api.GET("/users/:id/public", usersH.GetPublicProfile)
	api.GET("/callbacks/admob", callbacksH.AdMobSSV)

	trainingRepo := training.NewRepository(db)
	trainingSvc := training.NewService(trainingRepo, rdb, db)
	trainingH := training.NewHandler(trainingSvc)

	api.GET("/training/courses", trainingH.ListCourses)
	api.GET("/training/sections", trainingH.ListSections)
	api.GET("/training/sections/:id", trainingH.GetSection)
	api.GET("/training/sections/:id/path", trainingH.GetLearningPath) // Flutter uses this
	api.GET("/training/units/:id", trainingH.GetUnit)
	api.GET("/training/units/:id/levels", trainingH.GetUnit)             // Added fallback
	api.GET("/training/units/:id/questions", trainingH.GetUnitQuestions) // Flutter uses this
	api.GET("/training/levels/:id", trainingH.GetLevel)
	api.GET("/training/levels/:id/questions", trainingH.GetLevelQuestions) // Flutter uses this

	authTraining := api.Group("/training")
	authTraining.Use(middleware.Auth(cfg.JWTSecret))
	{
		authTraining.POST("/progress/submit", trainingH.SubmitProgress) // Flutter uses this
		authTraining.GET("/progress", trainingH.GetProgress)
		authTraining.GET("/progress/state", trainingH.GetProgress) // Alias for Flutter
	}

	cyberRepo := cyber.NewRepository(db)
	cyberSvc := cyber.NewService(cyberRepo, rdb)
	cyberH := cyber.NewHandler(cyberSvc)

	api.GET("/cyber/modules", cyberH.ListModules)
	api.GET("/cyber/modules/:id", cyberH.GetModule)

	authCyber := api.Group("/cyber")
	authCyber.Use(middleware.Auth(cfg.JWTSecret))
	{
		authCyber.GET("/challenges/:id", cyberH.GetChallenge)
		authCyber.POST("/challenges/:id/solve", cyberH.SolveChallenge)
	}

	sandiRepo := sandi.NewRepository(db)
	sandiSvc := sandi.NewService(sandiRepo, rdb)
	sandiH := sandi.NewHandler(sandiSvc)

	// Academy Studio (Authoring Ecosystem)
	studioH := studio.NewHandler()
	studioGrp := api.Group("/studio")
	{
		studioGrp.POST("/commands/update-block", studioH.HandleUpdateBlock)
		studioGrp.POST("/commands/preview-adaptive", studioH.HandlePreviewAdaptive)
	}

	// Skill Passport & Credentials
	passportH := passport.NewHandler()
	api.GET("/passports/:user_id", passportH.GetPublicPassport)
	api.GET("/passports/:user_id/evidence/:concept_id", passportH.GetEvidenceExplorer)

	// Marketplace logic removed in favor of Catalog V2

	api.GET("/sandi/types", sandiH.ListTypes)
	api.GET("/sandi/types/:id", sandiH.GetType)

	authSandi := api.Group("/sandi")
	authSandi.Use(middleware.Auth(cfg.JWTSecret))
	{
		authSandi.POST("/questions/:id/solve", sandiH.SolveQuestion)
		authSandi.POST("/encrypt", sandiH.Encrypt)
		authSandi.POST("/decrypt", sandiH.Decrypt)
	}

	// SKU (optional auth for listing, auth required for submit)
	skuRepo := sku.NewRepository(db)
	skuSvc := sku.NewService(skuRepo)
	skuH := sku.NewHandler(skuSvc)
	api.GET("/sku/points", skuH.ListPoints)
	api.GET("/sku/points/:id", skuH.GetPoint)

	// Core Services
	api.GET("/academies/:id/journeys/:curriculum_id", journeyH.GetAcademyJourney)
	api.GET("/academies/:id/journeys/:curriculum_id/nodes/:node_id/experience", journeyH.GetAdaptiveExperience)
	api.POST("/journey/complete-node", journeyH.CompleteNode)

	// Location
	locationRepo := location.NewRepository(db)
	locationSvc := location.NewService(locationRepo)
	locationH := location.NewHandler(locationSvc)

	api.GET("/location/provinsi", locationH.GetProvinsi)
	api.GET("/location/kabupaten", locationH.GetKabupaten)
	api.GET("/location/kecamatan", locationH.GetKecamatan)

	// Chat (Hierarchical) MUST be initialized BEFORE SKU so we can inject it
	chatRepo := chat.NewRepository(db)
	chatSvc := chat.NewService(chatRepo, rdb)
	chatH := chat.NewHandler(chatSvc)
	locationSvc.SetChatService(chatSvc)
	skuSvc.SetChatService(chatSvc)

	authChat := api.Group("/chat")
	authChat.Use(middleware.Auth(cfg.JWTSecret))
	{
		authChat.GET("/rooms", chatH.GetUserRooms)
		authChat.GET("/rooms/:room_id/messages", chatH.GetMessages)
		authChat.POST("/rooms/:room_id/messages", chatH.SendMessage)
		authChat.GET("/rooms/:room_id/info", chatH.GetRoomInfo)
		authChat.GET("/ws", chatH.ServeWS)
	}

	authLoc := api.Group("/location")
	authLoc.Use(middleware.Auth(cfg.JWTSecret))
	{
		authLoc.POST("/set", locationH.SetLocation)
		authLoc.GET("/me", locationH.GetMyLocation)
	}

	authAll := api.Group("")
	authAll.Use(middleware.Auth(cfg.JWTSecret))
	{
		// Aliases for Flutter
		authAll.GET("/users/:id/hearts", heartsH.GetHearts)
		authAll.POST("/users/:id/hearts/decrement", heartsH.Decrement)

		authAll.GET("/sku/time-gate-status", skuH.TimeGateStatus)

		// Survival
		survivalRepo := survival.NewRepository(db)
		survivalSvc := survival.NewService(survivalRepo)
		survivalH := survival.NewHandler(survivalSvc)

		// Leaderboard
		lbRepo := leaderboard.NewRepository(db, rdb)
		lbSvc := leaderboard.NewService(lbRepo)
		lbH := leaderboard.NewHandler(lbSvc)
		api.GET("/leaderboard", lbH.GetTop)
		api.GET("/survival/leaderboard", survivalH.GetLeaderboard)

		// Arena 5v5 & 1v1
		arenaRepo := arena.NewRepository(db)
		arenaSvc := arena.NewService(arenaRepo, rdb)
		arenaH := arena.NewHandler(arenaSvc, arenaRepo)

		authArena := api.Group("/arena")
		authArena.Use(middleware.Auth(cfg.JWTSecret))
		{
			authArena.GET("/rooms", arenaH.GetWaitingRooms)
			authArena.POST("/rooms", arenaH.CreateRoom)
			authArena.GET("/rooms/:code", arenaH.GetRoomStatus)
			authArena.POST("/rooms/:code/teams", arenaH.CreateTeam)
			authArena.POST("/rooms/:code/teams/:slot/join", arenaH.JoinTeam)
			authArena.POST("/rooms/:code/start", arenaH.StartRoom)
			authArena.GET("/rooms/:code/state", arenaH.GetRoomState)
			authArena.POST("/rooms/:code/answer", arenaH.SubmitAnswer)

			// 1v1
			authArena.POST("/matchmake/join", arenaH.Matchmake1v1)
			authArena.GET("/matchmake/status", arenaH.GetMatchmakeStatus)
			authArena.DELETE("/matchmake/cancel", arenaH.CancelMatchmake)
			authArena.POST("/matchmake/bot", arenaH.CreateBotMatch)
		}

		// TKK
		tkkRepo := tkk.NewRepository(db)
		tkkSvc := tkk.NewService(tkkRepo)
		tkkH := tkk.NewHandler(tkkSvc)
		authAll.GET("/tkk", tkkH.ListBadges)
		authAll.POST("/tkk/attain", tkkH.Attain)

		// Survival (auth)
		authAll.GET("/survival/status", survivalH.GetStatus)
		authAll.POST("/survival/action", survivalH.LogAction)

		// SKU submit (auth)
		authAll.POST("/sku/points/:id/submit", skuH.SubmitQuiz)

		// Token
		tokenRepo := token.NewPostgresTokenRepository(db)
		tokenSvc := token.NewTokenService(tokenRepo)
		tokenH := token.NewTokenHandler(tokenSvc)

		authAll.GET("/tokens/me", tokenH.GetStatus)
		authAll.POST("/tokens/consume", tokenH.ConsumeOne)

		// Subscription
		subRepo := subscription.NewRepository(db)
		subSvc := subscription.NewService(subRepo, tokenSvc)
		subH := subscription.NewHandler(subSvc)
		authAll.GET("/subscription", subH.GetStatus)
		authAll.POST("/subscription/create", subH.Create)
		authAll.POST("/subscription/cancel", subH.Cancel)

		// AI
		aiClient := ai.NewGeminiClient(cfg.GeminiAPIKey, cfg.GeminiModel)
		aiSvc := ai.NewAIService(aiClient, tokenSvc, cfg.AIMaxOutputTokens, cfg.AITemperature)
		aiH := ai.NewAIHandler(aiSvc)
		authAll.POST("/ai/chat", aiH.Chat)

		// CTF
		ctfRepo := ctf.NewPostgresCTFRepository(db)
		ctfSvc := ctf.NewCTFService(ctfRepo, arenaRepo, aiSvc, tokenSvc)
		ctfH := ctf.NewCTFHandler(ctfSvc)
		ctf.RegisterCTFRoutes(api, ctfH, middleware.Auth(cfg.JWTSecret))

		// Leaderboard (user rank requires auth)
		authAll.GET("/leaderboard/me", lbH.GetRank)

		// Evidence Validator / Submissions (Sprint YC Synchronous Execution)
		evRepo := evidence_validator.NewRepository(db)
		evQueue := evidence_validator.NewQueueClientFromClient(asynqClient)
		tutorSvc, _ := tutor.NewService(cfg.DeepSeekAPIKey, "deepseek-coder")
		evHandler := evidence_validator.NewHandler(evQueue, evRepo, pool, tutorSvc)
		authAll.POST("/submissions", evHandler.Submit)
		authAll.GET("/submissions/:id", evHandler.GetStatus)

		// Admin
		adminRepo := admin.NewRepository(db)
		adminSvc := admin.NewService(adminRepo)
		adminH := admin.NewHandler(adminSvc)

		adminGroup := api.Group("/admin")
		adminGroup.Use(middleware.Auth(cfg.JWTSecret))
		{
			adminGroup.GET("/users", adminH.ListUsers)
			adminGroup.PATCH("/users/:id", adminH.UpdateUser)
			adminGroup.POST("/sections", adminH.CreateSection)
			adminGroup.POST("/modules", adminH.CreateModule)
		}
	}

	return r
}
