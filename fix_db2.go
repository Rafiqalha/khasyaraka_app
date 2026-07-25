package main

import (
"log"
"database/sql"
_ "github.com/lib/pq"
)

func main() {
db, err := sql.Open("postgres", "postgres://scout_admin:scout_password_local@localhost:5432/scout_os?sslmode=disable")
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
