package mission

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/redis/go-redis/v9"
)

type MissionHub struct {
	rdb      *redis.Client
	clients  map[string]map[chan EnvironmentEvent]bool
	mu       sync.RWMutex
}

func NewMissionHub(rdb *redis.Client) *MissionHub {
	return &MissionHub{
		rdb:     rdb,
		clients: make(map[string]map[chan EnvironmentEvent]bool),
	}
}

func (h *MissionHub) Run() {}

func (h *MissionHub) Subscribe(missionID string, ch chan EnvironmentEvent) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if h.clients[missionID] == nil {
		h.clients[missionID] = make(map[chan EnvironmentEvent]bool)
	}
	h.clients[missionID][ch] = true
}

func (h *MissionHub) Unsubscribe(missionID string, ch chan EnvironmentEvent) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if h.clients[missionID] != nil {
		delete(h.clients[missionID], ch)
	}
}

func (h *MissionHub) Broadcast(missionID string, event EnvironmentEvent) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	data, _ := json.Marshal(event)
	h.rdb.Publish(context.Background(), fmt.Sprintf("mission_stream:%s", missionID), string(data))

	if chans, ok := h.clients[missionID]; ok {
		for ch := range chans {
			select {
			case ch <- event:
			default:
			}
		}
	}
}

var upgrader = websocket.Upgrader{
	ReadBufferSize: 1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}
