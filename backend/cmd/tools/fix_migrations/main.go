package main

import (
	"log"

	"github.com/pradigi/backend/internal/config"
	"github.com/pradigi/backend/internal/database"
)

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

	log.Println("Cleaning public schema on Supabase...")
	_, err = db.Exec("DROP SCHEMA public CASCADE; CREATE SCHEMA public;")
	if err != nil {
		log.Fatalf("Failed to reset schema: %v", err)
	}
	log.Println("Public schema reset successfully!")

	err = database.RunMigrations(cfg.DatabaseURL, "migrations")
	if err != nil {
		log.Fatalf("migration execution failed: %v", err)
	}

	log.Println("🎉 ALL 80+ MIGRATIONS APPLIED SUCCESSFULLY FROM FRESH START!")
}
