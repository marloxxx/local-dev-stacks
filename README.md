# local-dev-stacks

Local **Docker Compose** stacks for day-to-day development: **Postgres**, **Redis**, **MySQL**, **MinIO**, and **Mailpit**. Each service lives in its own folder so you can start or stop stacks independently in Docker Desktop (or CLI).

| Service   | Folder     | Default ports | Use case                          |
| --------- | ---------- | ------------- | --------------------------------- |
| Postgres  | `postgres/` | 5432         | Relational DB                     |
| Redis     | `redis/`    | 6379         | Cache / queues                    |
| MySQL     | `mysql/`    | 3306         | MySQL 8.4 apps                    |
| MinIO     | `minio/`    | 9000, 9001   | S3-compatible storage             |
| Mailpit   | `mailpit/`  | 1025, 8025   | SMTP capture + web UI             |

There is **no** root `docker-compose.yml`—by design, so each stack is a separate Compose project.

---

## Prerequisites

- **Docker** and **Docker Compose** v2 (`docker compose`)
- **Docker Desktop** (macOS/Windows) or Docker Engine + Compose on Linux

---

## Clone

```bash
git clone https://github.com/marloxxx/local-dev-stacks.git
cd local-dev-stacks
```

SSH:

```bash
git clone git@github.com:marloxxx/local-dev-stacks.git
cd local-dev-stacks
```

---

## Quick start

### Option A – One script (all stacks)

From the **repo root**:

```bash
chmod +x dev-stacks.sh   # once
./dev-stacks.sh up       # creates .env from .env.example if missing, then starts all
./dev-stacks.sh status   # compose ps per stack
./dev-stacks.sh down    # stop all
./dev-stacks.sh help    # usage
```

### Option B – Single service only

```bash
cd postgres
cp .env.example .env
docker compose up -d
```

Repeat for `redis/`, `minio/`, `mailpit/`, `mysql/` as needed.

---

## Connection reference

| Service  | Connection notes |
| -------- | ---------------- |
| **Postgres** | `postgresql://postgres:<password>@localhost:5432/postgres` — password in `postgres/.env` |
| **Redis**    | `redis://:<password>@localhost:6379/0` — password in `redis/.env` |
| **MySQL**    | `root` @ `localhost:3306` — **MySQL 8.4** (`caching_sha2_password`). Clients must support it or use TLS. If you change version or init fails, wipe `mysql/data` then `docker compose up -d` again. |
| **MinIO**    | API `http://localhost:9000`, console `http://localhost:9001` — credentials in `minio/.env` |
| **Mailpit**  | SMTP `localhost:1025`, UI http://localhost:8025 |

Default-style passwords are in each folder’s `.env.example` (copy to `.env`—never commit `.env`).

---

## Docker Desktop

- **Containers** shows one group per project (`postgres`, `redis`, …).
- Start/stop/restart each stack without affecting the others.
- Optional: **File → Open Folder** on a service folder to run Compose from the UI.

---

## Repo layout

```
local-dev-stacks/
├── dev-stacks.sh          # up | down | status | help
├── .env.example           # optional aggregate vars (each service has its own .env.example)
├── .gitignore
├── README.md
├── postgres/   docker-compose.yml  .env.example  data/   # data/ gitignored
├── redis/
├── minio/
├── mailpit/
└── mysql/
```

Stop one stack only:

```bash
cd postgres
docker compose down
```

---

## Troubleshooting

### Mailpit: port 1025 (or 8025) already allocated

1. **Free the port** — old Mailhog/Mailpit container may still be bound:
   ```bash
   docker ps -a | grep -E '1025|mailhog|mailpit'
   docker stop mailhog 2>/dev/null; docker rm mailhog 2>/dev/null
   ```
2. **Or change ports** in `mailpit/.env`:
   ```bash
   MAILPIT_SMTP_PORT=1026
   MAILPIT_UI_PORT=8026
   ```
   Point your app at SMTP `localhost:1026`; open UI at http://localhost:8026

### `git push` / SSH: Permission denied (publickey)

Use HTTPS remote and a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) when prompted for password:

```bash
git remote set-url origin https://github.com/marloxxx/local-dev-stacks.git
git push -u origin main
```

---

## Git

- **Tracked:** `docker-compose.yml`, `.env.example`, `dev-stacks.sh`, docs.
- **Ignored:** all `.env` files and every `**/data/` directory (DB volumes, Mailpit SQLite, etc.).

Do **not** commit real passwords; rotate anything that was ever committed by mistake.

---

## Licence

Use freely for local development.
