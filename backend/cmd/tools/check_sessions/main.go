package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/database"
)

type SessionInfo struct {
	ID                 string  `db:"id" json:"session_id"`
	UserID             int64   `db:"user_id" json:"user_id"`
	LearningGoalID     *string `db:"learning_goal_id" json:"learning_goal_id"`
	CurrentNodeID      *string `db:"current_node_id" json:"current_node_id"`
	Status             string  `db:"status" json:"status"`
	ProgressPercentage int     `db:"progress_percentage" json:"progress"`
	LastActivityAt     string  `db:"last_activity_at" json:"last_activity"`
}

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("config: %v", err)
	}

	db, err := database.NewPostgres(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("conn: %v", err)
	}
	defer db.Close()

	var sessions []SessionInfo
	err = db.Select(&sessions, "SELECT id, user_id, learning_goal_id, current_node_id, status, progress_percentage, last_activity_at FROM runtime_sessions ORDER BY last_activity_at DESC")
	if err != nil {
		log.Fatalf("query sessions err: %v", err)
	}

	fmt.Printf("=== DAFTAR SESI AKTIF (RUNTIME SESSIONS) DI SUPABASE (%d Sessions) ===\n", len(sessions))
	out, _ := json.MarshalIndent(sessions, "", "  ")
	fmt.Println(string(out))
}
