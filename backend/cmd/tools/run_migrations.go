package main

import (
	"fmt"
	"log"

	"github.com/pradigi/backend/internal/database"
)

func main() {
	err := database.RunMigrations("postgres://scout_admin:scout_password_local@localhost:5433/scout_os?sslmode=disable", "migrations")
	if err != nil {
		log.Fatalf("Migration failed: %v", err)
	}
	fmt.Println("Migrations successful")
}
