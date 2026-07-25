//go:build ignore

package main

import (
	"fmt"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"log"
)

func main() {
	db, err := sqlx.Connect("postgres", "host=localhost port=5432 user=pradigi dbname=pradigi password=pradigi sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	var count int
	err = db.Get(&count, "SELECT COUNT(*) FROM chat_messages WHERE room_id = 4")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Message count in room 4:", count)
}
