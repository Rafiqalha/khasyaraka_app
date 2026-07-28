package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/database"
)

type UserInfo struct {
	ID           int64   `db:"id" json:"id"`
	FullName     *string `db:"full_name" json:"full_name"`
	Email        string  `db:"email" json:"email"`
	TotalXP      int     `db:"total_xp" json:"total_xp"`
	HackLevel    *string `db:"hack_level" json:"hack_level"`
	IsActive     bool    `db:"is_active" json:"is_active"`
	IsSuperuser  bool    `db:"is_superuser" json:"is_superuser"`
	CreatedAt    string  `db:"created_at" json:"created_at"`
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

	var users []UserInfo
	err = db.Select(&users, "SELECT id, full_name, email, total_xp, hack_level, is_active, is_superuser, created_at FROM users ORDER BY id ASC")
	if err != nil {
		log.Fatalf("query users err: %v", err)
	}

	fmt.Printf("=== DAFTAR USER TERDAFTAR DI SUPABASE (%d Users) ===\n", len(users))
	out, _ := json.MarshalIndent(users, "", "  ")
	fmt.Println(string(out))
}
