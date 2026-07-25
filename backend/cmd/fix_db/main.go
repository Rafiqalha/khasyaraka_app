package main

import (
	"database/sql"
	"fmt"
	"log"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
	"github.com/pradigi/backend/internal/config"
)

func main() {
	godotenv.Load("../.env")
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Error loading config: %v", err)
	}

	db, err := sql.Open("postgres", cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
	}
	defer db.Close()

	fmt.Println("Connected to db")

	// Drop old tables
	_, err = db.Exec(`
		ALTER TABLE IF EXISTS journeys DROP CONSTRAINT IF EXISTS fk_journey_latest_pack CASCADE;
		DROP TABLE IF EXISTS packs CASCADE;
		DROP TABLE IF EXISTS journeys CASCADE;
	`)
	if err != nil {
		fmt.Printf("Error dropping old tables: %v\n", err)
	} else {
		fmt.Println("Dropped journeys and packs tables successfully.")
	}

	// Decrement schema_migrations to force it to rerun 36
	_, err = db.Exec(`UPDATE schema_migrations SET version = 35, dirty = false;`)
	if err != nil {
		fmt.Printf("Error updating schema_migrations: %v\n", err)
	} else {
		fmt.Println("Updated schema_migrations successfully.")
	}
}
