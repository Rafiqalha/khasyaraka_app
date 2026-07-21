package game_modes

import (
	"encoding/json"
	"net/http"
	"strconv"
)

type GameModeHandler struct {
	lobby *LobbyService
	game  *GameService
}

func NewGameModeHandler(lobby *LobbyService, game *GameService) *GameModeHandler {
	return &GameModeHandler{lobby: lobby, game: game}
}

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]string{"error": msg})
}

func (h *GameModeHandler) GetModes(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"modes": ModeCards,
	})
}

func (h *GameModeHandler) CreateLobby(w http.ResponseWriter, r *http.Request) {
	var req CreateLobbyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid body")
		return
	}

	room, err := h.lobby.CreateLobby(req.UserID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"code": room.Code,
		"room": room,
	})
}

func (h *GameModeHandler) JoinLobby(w http.ResponseWriter, r *http.Request) {
	var req JoinLobbyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid body")
		return
	}

	room, err := h.lobby.JoinLobby(req.Code, req.UserID)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"room": room,
	})
}

func (h *GameModeHandler) GetLobbyState(w http.ResponseWriter, r *http.Request) {
	code := r.URL.Query().Get("code")
	if code == "" {
		writeError(w, http.StatusBadRequest, "code required")
		return
	}

	room, players, err := h.lobby.GetLobby(code)
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}

	resp := LobbyStateResponse{
		Room:    *room,
		Modes:   ModeCards,
		Players: players,
	}
	writeJSON(w, http.StatusOK, resp)
}

func (h *GameModeHandler) SelectMode(w http.ResponseWriter, r *http.Request) {
	var req SelectModeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid body")
		return
	}

	if err := h.lobby.SelectMode(req.Code, req.Mode); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (h *GameModeHandler) StartGame(w http.ResponseWriter, r *http.Request) {
	var req StartGameRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid body")
		return
	}

	room, err := h.lobby.StartGame(req.Code)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"room": room,
	})
}

func (h *GameModeHandler) SubmitAction(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.Header.Get("X-User-ID")
	userID, err := strconv.ParseInt(userIDStr, 10, 64)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "user id required in X-User-ID header")
		return
	}

	var req SubmitActionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid body")
		return
	}

	action, round, err := h.game.SubmitAction(req.Code, userID, req.Input)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"action": action,
		"round":  round,
	})
}

func (h *GameModeHandler) GetGameState(w http.ResponseWriter, r *http.Request) {
	code := r.URL.Query().Get("code")
	if code == "" {
		writeError(w, http.StatusBadRequest, "code required")
		return
	}

	userIDStr := r.Header.Get("X-User-ID")
	userID, _ := strconv.ParseInt(userIDStr, 10, 64)

	state, err := h.game.GetGameState(code, userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	writeJSON(w, http.StatusOK, state)
}
