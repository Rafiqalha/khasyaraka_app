package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"github.com/pradigi/backend/internal/core/telemetry"
)

func main() {
	db, err := sqlx.Connect("postgres", "postgres://scout_admin:scout_password_local@localhost:5433/scout_os?sslmode=disable")
	if err != nil {
		log.Fatalln(err)
	}
	defer db.Close()

	// Simulate Flutter sending batch payload
	episodeID := uuid.NewString()
	payload := map[string]interface{}{
		"episode_id":     episodeID,
		"activity_id":    "activity_01",
		"mission_id":     "mission_123",
		"schema_version": "1.0.0",
		"intent_evolution": map[string]interface{}{
			time.Now().Format(time.RFC3339): "Learn Python",
		},
		"events": []map[string]interface{}{
			{
				"id":          uuid.NewString(),
				"event_type":  "ThinkingStarted",
				"timestamp":   time.Now(),
				"duration_ms": 1500,
				"payload":     map[string]interface{}{"focus": "editor"},
			},
		},
		"snapshots": []map[string]interface{}{
			{
				"snapshot_type": "workspace",
				"data": map[string]interface{}{
					"files": map[string]string{"main.go": "package main"},
				},
			},
		},
		"reflections": []map[string]interface{}{
			{
				"question": "What was the hardest part?",
				"answer":   "Understanding PII sanitization for my test@example.com account and API key sk-123456789012345678901234567890123456789012345678",
			},
		},
	}

	b, _ := json.Marshal(payload)
	resp, err := http.Post("http://localhost:8080/api/v1/telemetry/batch", "application/json", bytes.NewBuffer(b))
	if err != nil {
		log.Fatalf("Failed to post: %v", err)
	}
	defer resp.Body.Close()

	respBytes, _ := io.ReadAll(resp.Body)
	fmt.Printf("API Response: %s\n", string(respBytes))

	// Verify Assembler
	sanitizer := telemetry.NewSanitizer()
	assembler := telemetry.NewAssembler(db, sanitizer)

	assembled, err := assembler.Assemble(context.Background(), episodeID)
	if err != nil {
		log.Fatalf("Failed to assemble: %v", err)
	}

	out, _ := json.MarshalIndent(assembled, "", "  ")
	fmt.Printf("\nAssembled JSON:\n%s\n", string(out))
}
