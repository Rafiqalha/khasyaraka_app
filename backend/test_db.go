//go:build ignore

package main

import (
"fmt"
"log"

"github.com/jmoiron/sqlx"
_ "github.com/lib/pq"
)

func main() {
db, err := sqlx.Connect("postgres", "host=localhost port=5432 user=khasyaraka dbname=khasyaraka password=khasyaraka sslmode=disable")
if err != nil {
log.Fatal(err)
}

var tables []string
err = db.Select(&tables, "SELECT table_name FROM information_schema.tables WHERE table_schema='public'")
if err != nil {
log.Fatal(err)
}
fmt.Println("Tables:", tables)
}
