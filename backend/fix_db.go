package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

func main() {
	dbURL := "postgres://scout_admin:scout_password_local@localhost:5433/scout_os?sslmode=disable"
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer db.Close()

	_, err = db.Exec("UPDATE schema_migrations SET version = 60, dirty = false;")
	if err != nil {
		log.Fatalf("Update failed: %v", err)
	}

	_, err = db.Exec(`
		DROP TABLE IF EXISTS learning_feature_vectors CASCADE;
		DROP TABLE IF EXISTS user_competencies CASCADE;
		DROP TABLE IF EXISTS activity_competencies CASCADE;
		DROP TABLE IF EXISTS pack_activities CASCADE;
		DROP TABLE IF EXISTS path_packs CASCADE;
		DROP TABLE IF EXISTS learning_paths CASCADE;
		DROP TABLE IF EXISTS competency_prerequisites CASCADE;
		DROP TABLE IF EXISTS competencies CASCADE;
	`)
	if err != nil {
		log.Fatalf("Drop failed: %v", err)
	}

	fmt.Println("Fixed dirty DB")
}
