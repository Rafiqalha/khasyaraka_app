package chat

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for mobile app
	},
}

type WsClient struct {
	UserID int64
	Conn   *websocket.Conn
	Rooms  []string // List of room channels they are subscribed to (e.g., "room:1", "room:5")
}

type WsHub struct {
	clients    map[int64]*WsClient
	register   chan *WsClient
	unregister chan *WsClient
	mu         sync.Mutex
	redis      *redis.Client
	ctx        context.Context
}

func NewWsHub(rdb *redis.Client) *WsHub {
	return &WsHub{
		clients:    make(map[int64]*WsClient),
		register:   make(chan *WsClient),
		unregister: make(chan *WsClient),
		redis:      rdb,
		ctx:        context.Background(),
	}
}

func (h *WsHub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			// If already connected, close old one
			if oldClient, ok := h.clients[client.UserID]; ok {
				oldClient.Conn.Close()
			}
			h.clients[client.UserID] = client
			h.mu.Unlock()

			// Subscribe to Redis for all their rooms
			go h.subscribeToRooms(client)

		case client := <-h.unregister:
			h.mu.Lock()
			if c, ok := h.clients[client.UserID]; ok && c == client {
				delete(h.clients, client.UserID)
				c.Conn.Close()
			}
			h.mu.Unlock()
		}
	}
}

func (h *WsHub) subscribeToRooms(client *WsClient) {
	if len(client.Rooms) == 0 {
		return
	}

	pubsub := h.redis.Subscribe(h.ctx, client.Rooms...)
	defer pubsub.Close()

	ch := pubsub.Channel()
	for {
		select {
		case msg, ok := <-ch:
			if !ok {
				return
			}
			// Write the raw JSON message back to the client
			err := client.Conn.WriteMessage(websocket.TextMessage, []byte(msg.Payload))
			if err != nil {
				h.unregister <- client
				return
			}
		}
	}
}

func (h *WsHub) BroadcastToRoom(roomID int64, message *ChatMessage) {
	channel := fmt.Sprintf("room:%d", roomID)
	data, _ := json.Marshal(message)
	h.redis.Publish(h.ctx, channel, string(data))
}

func (s *Service) ServeWS(c *gin.Context, userID int64) {
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("ws upgrade error:", err)
		return
	}

	// Get user rooms
	rooms, err := s.GetUserRooms(c.Request.Context(), userID)
	if err != nil {
		conn.Close()
		return
	}

	var roomChannels []string
	if rooms.Kecamatan != nil {
		roomChannels = append(roomChannels, fmt.Sprintf("room:%d", rooms.Kecamatan.ID))
	}
	if rooms.Kabupaten != nil {
		roomChannels = append(roomChannels, fmt.Sprintf("room:%d", rooms.Kabupaten.ID))
	}
	if rooms.Provinsi != nil {
		roomChannels = append(roomChannels, fmt.Sprintf("room:%d", rooms.Provinsi.ID))
	}
	if rooms.Nasional != nil {
		roomChannels = append(roomChannels, fmt.Sprintf("room:%d", rooms.Nasional.ID))
	}

	client := &WsClient{
		UserID: userID,
		Conn:   conn,
		Rooms:  roomChannels,
	}

	s.hub.register <- client

	// Read loop to detect disconnects
	go func() {
		defer func() {
			s.hub.unregister <- client
		}()
		for {
			_, _, err := conn.ReadMessage()
			if err != nil {
				break
			}
		}
	}()
}
