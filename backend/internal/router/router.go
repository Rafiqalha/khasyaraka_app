package router

import (
	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
	applogger "github.com/pradigi/backend/internal/pkg/logger"

	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/middleware"
	"github.com/pradigi/backend/internal/modules/admin"
	"github.com/pradigi/backend/internal/modules/auth"
	"github.com/pradigi/backend/internal/modules/callbacks"
	"github.com/pradigi/backend/internal/academies/cyber/arena"
	"github.com/pradigi/backend/internal/modules/chat"
	"github.com/pradigi/backend/internal/academies/cyber/cyber"
	"github.com/pradigi/backend/internal/legacy/hearts"
	"github.com/pradigi/backend/internal/legacy/leaderboard"
	"github.com/pradigi/backend/internal/modules/location"
	"github.com/pradigi/backend/internal/academies/scout/sandi"
	"github.com/pradigi/backend/internal/academies/scout/sku"
	"github.com/pradigi/backend/internal/modules/subscription"
	"github.com/pradigi/backend/internal/academies/scout/survival"
	"github.com/pradigi/backend/internal/academies/scout/tkk"
	"github.com/pradigi/backend/internal/marketplace"
	"github.com/pradigi/backend/internal/modules/training"
	"github.com/pradigi/backend/internal/modules/users"
	"github.com/pradigi/backend/internal/core/journey"
	"github.com/pradigi/backend/internal/core/passport"
	"github.com/pradigi/backend/internal/legacy/token"
	"github.com/pradigi/backend/internal/modules/ai"
	"github.com/pradigi/backend/internal/academies/cyber/ctf"
	"github.com/pradigi/backend/internal/studio"
)

func New(cfg *config.Config, db *sqlx.DB, rdb *redis.Client) *gin.Engine {
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(middleware.CORS(cfg.CORSOrigins))
	r.Use(middleware.Logger())

	api := r.Group("/api/v1")

	api.GET("/health", healthHandler(db, rdb))

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

	journeyH := journey.NewHandler(".")

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
	api.POST("/users/:id/hearts/debug-increment", heartsH.DebugIncrement)
	api.GET("/callbacks/admob", callbacksH.AdMobSSV)

	trainingRepo := training.NewRepository(db)
	trainingSvc := training.NewService(trainingRepo, rdb, db)
	trainingH := training.NewHandler(trainingSvc)

	api.GET("/training/courses", trainingH.ListCourses)
	api.GET("/training/sections", trainingH.ListSections)
	api.GET("/training/sections/:id", trainingH.GetSection)
	api.GET("/training/sections/:id/path", trainingH.GetLearningPath) // Flutter uses this
	api.GET("/training/units/:id", trainingH.GetUnit)
	api.GET("/training/units/:id/levels", trainingH.GetUnit) // Added fallback
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

	// Marketplace (Package Distribution System)
	pkgManager := marketplace.NewPackageManager("1.0.0") // Pradigi OS v1.0.0
	marketH := marketplace.NewHandler(pkgManager)
	marketGrp := api.Group("/marketplace")
	{
		marketGrp.GET("/search", marketH.Search)
		marketGrp.GET("/packages/:id", marketH.GetPackageDetail)
		marketGrp.POST("/packages/:id/install", marketH.Install)
		marketGrp.GET("/installed", marketH.ListInstalled)
	}

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

		// Admin
		adminRepo := admin.NewRepository(db)
		adminSvc := admin.NewService(adminRepo)
		adminH := admin.NewHandler(adminSvc)
		authAll.GET("/admin/users", adminH.ListUsers)
		authAll.PATCH("/admin/users/:id", adminH.UpdateUser)
		authAll.POST("/admin/sections", adminH.CreateSection)
		authAll.POST("/admin/modules", adminH.CreateModule)
	}

	return r
}
