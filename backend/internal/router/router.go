package router

import (
	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
	"github.com/redis/go-redis/v9"
	"github.com/rs/zerolog"

	"github.com/khasyaraka/backend/internal/config"
	"github.com/khasyaraka/backend/internal/middleware"
	"github.com/khasyaraka/backend/internal/modules/admin"
	"github.com/khasyaraka/backend/internal/modules/auth"
	"github.com/khasyaraka/backend/internal/modules/callbacks"
	"github.com/khasyaraka/backend/internal/modules/cyber"
	"github.com/khasyaraka/backend/internal/modules/hearts"
	"github.com/khasyaraka/backend/internal/modules/leaderboard"
	"github.com/khasyaraka/backend/internal/modules/sandi"
	"github.com/khasyaraka/backend/internal/modules/sku"
	"github.com/khasyaraka/backend/internal/modules/subscription"
	"github.com/khasyaraka/backend/internal/modules/survival"
	"github.com/khasyaraka/backend/internal/modules/tkk"
	"github.com/khasyaraka/backend/internal/modules/training"
	"github.com/khasyaraka/backend/internal/modules/users"
)

func New(cfg *config.Config, db *sqlx.DB, rdb *redis.Client, logger zerolog.Logger) *gin.Engine {
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(middleware.CORS(cfg.CORSOrigins))
	r.Use(middleware.Logger(logger))

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

	usersRepo := users.NewRepository(db)
	usersSvc := users.NewService(usersRepo)
	usersH := users.NewHandler(usersSvc)

	heartsSvc := hearts.NewService(db, rdb)
	heartsH := hearts.NewHandler(heartsSvc)

	callbacksH := callbacks.NewHandler(heartsSvc, rdb, logger, cfg.Environment)

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

	api.GET("/training/sections", trainingH.ListSections)
	api.GET("/training/sections/:id", trainingH.GetSection)
	api.GET("/training/units/:id", trainingH.GetUnit)

	authTraining := api.Group("/training")
	authTraining.Use(middleware.Auth(cfg.JWTSecret))
	{
		authTraining.GET("/levels/:id", trainingH.GetLevel)
		authTraining.POST("/levels/:id/submit", trainingH.SubmitLevel)
		authTraining.GET("/progress", trainingH.GetProgress)
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

	authAll := api.Group("")
	authAll.Use(middleware.Auth(cfg.JWTSecret))
	{
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

		// Subscription
		subRepo := subscription.NewRepository(db)
		subSvc := subscription.NewService(subRepo)
		subH := subscription.NewHandler(subSvc)
		authAll.GET("/subscription", subH.GetStatus)
		authAll.POST("/subscription/create", subH.Create)
		authAll.POST("/subscription/cancel", subH.Cancel)

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
