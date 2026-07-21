package ctf

import "github.com/gin-gonic/gin"

func RegisterCTFRoutes(router *gin.RouterGroup, handler *CTFHandler, authMiddleware gin.HandlerFunc) {
	ctfGroup := router.Group("/ctf")
	ctfGroup.Use(authMiddleware)
	{
		ctfGroup.POST("/rooms/:room_id/init", handler.InitializeRoom)
		ctfGroup.POST("/rooms/:room_id/start-defense", handler.StartDefensePhase)
		ctfGroup.POST("/rooms/:room_id/defense", handler.SubmitDefense)
		ctfGroup.POST("/rooms/:room_id/start-attack", handler.StartAttackPhase)
		ctfGroup.POST("/rooms/:room_id/attack/ai", handler.AttackWithAI)
		ctfGroup.POST("/rooms/:room_id/attack/flag", handler.SubmitFlag)
		ctfGroup.POST("/rooms/:room_id/patch", handler.SubmitPatch)
		ctfGroup.GET("/rooms/:room_id/state", handler.GetState)
		ctfGroup.GET("/rooms/:room_id/finish", handler.FinishCTF)
	}
}
