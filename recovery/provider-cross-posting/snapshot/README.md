# evgl-web-mash

Authenticated MASH presentation server for Evento Globolo.

- public product home
- Argon2-protected organizer login
- signed, HTTP-only session cookie
- provider capability and connection workspace
- OAuth connection starts delegated to `evgl-api`
- per-user API JWTs minted from the web session
- provider job page with a bounded same-origin WebSocket control channel
- Postgres user storage through SQLx migrations

`EVGL_WEB_JWT_SECRET` must match the API `JWT_SECRET` in this scaffold. In a production deployment replace the local login table with the organization-wide Shared Auth exchange, while preserving the API subject and tenant claims.

```sh
cp .env.example .env
cargo run
```
