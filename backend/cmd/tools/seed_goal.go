package main

import (
	"log"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

func main() {
	db, err := sqlx.Connect("postgres", "postgres://scout_admin:scout_password_local@localhost:5433/scout_os?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	query := `
		INSERT INTO learning_goals (id, specialization_id, title, description, learning_objective) 
		VALUES ('cyber_soc_analyst', 'soc-analyst', 'SOC Analyst', 'Learn how attackers think and defend critical systems.', 'Master the fundamentals of SOC operations.') 
		ON CONFLICT (id) DO NOTHING;
	`
	_, err = db.Exec(query)
	if err != nil {
		log.Fatal("Failed to insert learning goal:", err)
	}
	log.Println("Successfully inserted cyber_soc_analyst")
}
