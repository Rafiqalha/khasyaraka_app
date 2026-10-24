package router

import (
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"

	"github.com/pradigi/backend/internal/academies/cyber/arena"
	"github.com/pradigi/backend/internal/academies/cyber/ctf"
	"github.com/pradigi/backend/internal/academies/scout/sandi"
	"github.com/pradigi/backend/internal/academies/scout/sku"
	"github.com/pradigi/backend/internal/academies/scout/survival"
	"github.com/pradigi/backend/internal/academies/scout/tkk"
	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/core/journey"
	"github.com/pradigi/backend/internal/core/passport"
	"github.com/pradigi/backend/internal/legacy/admin"
	"github.com/pradigi/backend/internal/legacy/ai"
	"github.com/pradigi/backend/internal/legacy/callbacks"
	"github.com/pradigi/backend/internal/legacy/chat"
	"github.com/pradigi/backend/internal/legacy/hearts"
	"github.com/pradigi/backend/internal/legacy/leaderboard"
	"github.com/pradigi/backend/internal/legacy/location"
	"github.com/pradigi/backend/internal/legacy/token"
	"github.com/pradigi/backend/internal/middleware"
	"github.com/pradigi/backend/internal/modules/subscription"
	applogger "github.com/pradigi/backend/internal/pkg/logger"
	"github.com/pradigi/backend/internal/studio"
)

// registerLegacyRoutes registers deprecated/compatibility routes.
// NOTE: These routes are marked for deprecation as part of Architecture v1.0 -> v2.0 migration.
func registerLegacyRoutes(
	api *gin.RouterGroup,
	cfg *config.Config,
	db *sqlx.DB,
	rdb *redis.Client,
) {
	heartsSvc := hearts.NewService(db, rdb)
	heartsH := hearts.NewHandler(heartsSvc)

	callbacksH := callbacks.NewHandler(heartsSvc, rdb, applogger.Get(), cfg.Environment)
	api.GET("/callbacks/admob", callbacksH.AdMobSSV)

	// Me (Hearts aliases)
	me := api.Group("/me")
	me.Use(middleware.Auth(cfg.JWTSecret))
	{
		me.GET("/hearts", heartsH.GetHearts)
		me.POST("/hearts/decrement", heartsH.Decrement)
	}

	// Sandi (Scout Ciphers)
	sandiRepo := sandi.NewRepository(db)
	sandiSvc := sandi.NewService(sandiRepo, rdb)
	sandiH := sandi.NewHandler(sandiSvc)

	api.GET("/sandi/types", sandiH.ListTypes)
	api.GET("/sandi/types/:id", sandiH.GetType)

	authSandi := api.Group("/sandi")
	authSandi.Use(middleware.Auth(cfg.JWTSecret))
	{
		authSandi.POST("/questions/:id/solve", sandiH.SolveQuestion)
		authSandi.POST("/encrypt", sandiH.Encrypt)
		authSandi.POST("/decrypt", sandiH.Decrypt)
	}

	// Academy Studio
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

	// SKU
	skuRepo := sku.NewRepository(db)
	skuSvc := sku.NewService(skuRepo)
	skuH := sku.NewHandler(skuSvc)
	api.GET("/sku/points", skuH.ListPoints)
	api.GET("/sku/points/:id", skuH.GetPoint)

	// Journey Legacy Nodes
	journeyH := journey.NewHandler(filepath.Dir("academies"))
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

	// Chat (Hierarchical)
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

	// Arena
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

	// Token Economy & Subscriptions
	tokenRepo := token.NewPostgresTokenRepository(db)
	tokenSvc := token.NewTokenService(tokenRepo)
	tokenH := token.NewTokenHandler(tokenSvc)

	subRepo := subscription.NewRepository(db)
	subSvc := subscription.NewService(subRepo, tokenSvc)
	subH := subscription.NewHandler(subSvc)

	// Legacy AI Chat
	legacyAIClient := ai.NewGeminiClient(cfg.GeminiAPIKey, cfg.GeminiModel)
	legacyAISvc := ai.NewAIService(legacyAIClient, tokenSvc, cfg.AIMaxOutputTokens, cfg.AITemperature)
	legacyAIH := ai.NewAIHandler(legacyAISvc)

	// CTF Arena
	ctfRepo := ctf.NewPostgresCTFRepository(db)
	ctfSvc := ctf.NewCTFService(ctfRepo, arenaRepo, legacyAISvc, tokenSvc)
	ctfH := ctf.NewCTFHandler(ctfSvc)
	ctf.RegisterCTFRoutes(api, ctfH, middleware.Auth(cfg.JWTSecret))

	// Authenticated General Routes
	authAll := api.Group("")
	authAll.Use(middleware.Auth(cfg.JWTSecret))
	{
		authAll.GET("/users/:id/hearts", heartsH.GetHearts)
		authAll.POST("/users/:id/hearts/decrement", heartsH.Decrement)
		authAll.GET("/sku/time-gate-status", skuH.TimeGateStatus)
		authAll.POST("/sku/points/:id/submit", skuH.SubmitQuiz)
		authAll.GET("/survival/status", survivalH.GetStatus)
		authAll.POST("/survival/action", survivalH.LogAction)
		authAll.GET("/tkk", tkkH.ListBadges)
		authAll.POST("/tkk/attain", tkkH.Attain)
		authAll.GET("/tokens/me", tokenH.GetStatus)
		authAll.POST("/tokens/consume", tokenH.ConsumeOne)
		authAll.GET("/subscription", subH.GetStatus)
		authAll.POST("/subscription/create", subH.Create)
		authAll.POST("/subscription/cancel", subH.Cancel)
		authAll.POST("/ai/chat", legacyAIH.Chat)
		authAll.GET("/leaderboard/me", lbH.GetRank)
	}

	// Admin Endpoints
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
