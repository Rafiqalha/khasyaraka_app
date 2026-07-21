package arena

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type Handler struct {
	svc  *Service
	repo *Repository
}

func NewHandler(svc *Service, repo *Repository) *Handler {
	return &Handler{svc: svc, repo: repo}
}

func requireID(c *gin.Context) (int64, bool) {
	idStr := c.GetString("user_id")
	if idStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "authentication required", "success": false})
		return 0, false
	}
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid user id", "success": false})
		return 0, false
	}
	return id, true
}

func (h *Handler) GetWaitingRooms(c *gin.Context) {
	rooms, err := h.repo.GetWaitingRooms(20)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": rooms})
}

func (h *Handler) CreateRoom(c *gin.Context) {
	uid, ok := requireID(c)
	if !ok {
		return
	}

	room, err := h.svc.CreateRoom(uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}

	// Auto create a team for the host
	hostTeam := &Team{
		RoomID:        room.ID,
		Name:          "Host Team",
		Slot:          1,
		CaptainUserID: uid,
	}
	_ = h.repo.CreateTeam(hostTeam)
	player := &Player{
		TeamID:    hostTeam.ID,
		RoomID:    room.ID,
		UserID:    uid,
		IsCaptain: true,
	}
	_ = h.repo.AddPlayerToTeam(player)

	c.JSON(http.StatusCreated, gin.H{"success": true, "data": room})
}

func (h *Handler) GetRoomStatus(c *gin.Context) {
	code := c.Param("code")

	room, err := h.repo.GetRoomByCode(code)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}
	if room == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "room not found", "success": false})
		return
	}

	teams, _ := h.repo.GetTeamsByRoomID(room.ID)
	players, _ := h.repo.GetPlayersByRoomID(room.ID)

	// Group players by team
	for i := range teams {
		for _, p := range players {
			if p.TeamID == teams[i].ID {
				teams[i].Players = append(teams[i].Players, p)
			}
		}
	}
	room.Teams = teams

	c.JSON(http.StatusOK, gin.H{"success": true, "data": room})
}

func (h *Handler) CreateTeam(c *gin.Context) {
	code := c.Param("code")
	uid, ok := requireID(c)
	if !ok {
		return
	}

	var req CreateTeamRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	err := h.svc.CreateTeam(code, req, uid)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "Team created and joined"})
}

func (h *Handler) JoinTeam(c *gin.Context) {
	code := c.Param("code")
	slotStr := c.Param("slot")
	slot, err := strconv.Atoi(slotStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid slot", "success": false})
		return
	}

	uid, ok := requireID(c)
	if !ok {
		return
	}

	err = h.svc.JoinTeam(code, slot, uid)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Joined team successfully"})
}

func (h *Handler) StartRoom(c *gin.Context) {
	code := c.Param("code")
	uid, ok := requireID(c)
	if !ok {
		return
	}

	err := h.svc.StartRoom(code, uid)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Room started"})
}

func (h *Handler) GetRoomState(c *gin.Context) {
	code := c.Param("code")
	uid, ok := requireID(c)
	if !ok {
		return
	}

	state, err := h.svc.GetRoomState(code, uid)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": state})
}

func (h *Handler) SubmitAnswer(c *gin.Context) {
	code := c.Param("code")
	uid, ok := requireID(c)
	if !ok {
		return
	}

	var req AnswerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	ans, err := h.svc.SubmitAnswer(code, uid, req)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": ans})
}

// 1v1 Matchmaking
func (h *Handler) Matchmake1v1(c *gin.Context) {
	uid, ok := requireID(c)
	if !ok {
		return
	}

	roomCode, err := h.svc.Matchmake1v1(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"room_code": roomCode}})
}

func (h *Handler) GetMatchmakeStatus(c *gin.Context) {
	uid, ok := requireID(c)
	if !ok {
		return
	}

	roomCode, err := h.svc.GetMatchmakeStatus(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"room_code": roomCode}})
}

func (h *Handler) CancelMatchmake(c *gin.Context) {
	uid, ok := requireID(c)
	if !ok {
		return
	}

	err := h.svc.CancelMatchmake(c.Request.Context(), uid)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "cancelled"})
}

type BotMatchRequest struct {
	Difficulty string `json:"difficulty"`
}

func (h *Handler) CreateBotMatch(c *gin.Context) {
	uid, ok := requireID(c)
	if !ok {
		return
	}

	var req BotMatchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "success": false})
		return
	}

	roomCode, err := h.svc.CreateBotMatch(c.Request.Context(), uid, req.Difficulty)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error(), "success": false})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{"room_code": roomCode}})
}
