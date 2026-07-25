package main

import (
"log"
"github.com/jmoiron/sqlx"
_ "github.com/lib/pq"
)

func main() {
db, err := sqlx.Connect("postgres", "postgres://scout_admin:scout_password_local@localhost:5432/scout_os?sslmode=disable")
if err != nil {
(err)
}
defer db.Close()
_, err = db.Exec("UPDATE schema_migrations SET dirty = false")
if err != nil {
(err)
}
log.Println("Database cleaned!")
}
