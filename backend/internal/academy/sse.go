package academy

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/pradigi/backend/internal/pkg/logger"
)

// StreamUpdates creates an SSE connection to listen for AI Director updates.
func (h *Handler) StreamUpdates(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Set headers for SSE
	c.Writer.Header().Set("Content-Type", "text/event-stream")
	c.Writer.Header().Set("Cache-Control", "no-cache")
	c.Writer.Header().Set("Connection", "keep-alive")
	c.Writer.Header().Set("Transfer-Encoding", "chunked")
	c.Writer.Header().Set("Access-Control-Allow-Origin", "*")

	// Flush the headers immediately
	c.Writer.Flush()

	// Subscribe to Redis PubSub for this specific user
	pubsubKey := fmt.Sprintf("director:finished:%s", userID)
	pubsub := h.rdb.Subscribe(c.Request.Context(), pubsubKey)
	defer pubsub.Close()

	ch := pubsub.Channel()

	clientGone := c.Writer.CloseNotify()

	logger.Info().Str("user", userID).Msg("SSE client connected")

	for {
		select {
		case <-clientGone:
			logger.Info().Str("user", userID).Msg("SSE client disconnected")
			return
		case <-c.Request.Context().Done():
			return
		case msg := <-ch:
			// Push the JSON payload to the client
			c.Render(-1, sseEvent{
				Event: "director_update",
				Data:  msg.Payload,
			})
			c.Writer.Flush()
		}
	}
}

// sseEvent is a custom renderer for Server-Sent Events
type sseEvent struct {
	Event string
	Data  string
}

func (r sseEvent) Render(w http.ResponseWriter) error {
	r.WriteContentType(w)
	_, err := fmt.Fprintf(w, "event: %s\ndata: %s\n\n", r.Event, r.Data)
	return err
}

func (r sseEvent) WriteContentType(w http.ResponseWriter) {
	header := w.Header()
	if val := header["Content-Type"]; len(val) == 0 {
		header["Content-Type"] = []string{"text/event-stream"}
	}
}
