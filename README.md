# rust-api-server

A simple API server written in Rust with a non-persistent Postgres data backend.

Uses info/code from these references:
- https://medium.com/better-programming/rest-api-in-rust-step-by-step-guide-b8a6c5fcbff0
- https://shaneutt.com/blog/rust-fast-small-docker-image-builds/
- https://docs.rs/diesel_migrations/1.4.0/diesel_migrations/macro.embed_migrations.html (https://www.reddit.com/r/rust/comments/bcrcp0/how_to_run_diesel_migration_automatically_on_prod/)

Other examples of this sort of thing:

- https://github.com/ghotiphud/rust-web-starter

## Interfacing via curl

You can access three endpoints with minimal effort as-is:

- /users: This returns all users currently stored in the database.
  curl http://localhost:8000/api/v1/users
- /newUser: This adds a new user. Requires the newuser.json file.
  curl -X POST -H "Content-Type: application/json" -d @newuser.json http://localhost:8000/api/v1/newUser
- /getUser: Returns a given user. Requires the newuser.json file.
  curl -X POST -H "Content-Type: application/json" -d @newuser.json http://localhost:8000/api/v1/getUser
