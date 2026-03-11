# Local development (Docker)

Each service is **its own Compose project** so you can start/stop and manage them separately in **Docker Desktop** (Containers / Compose view per stack).

| Folder    | Compose project name | Container   | Ports        |
| --------- | -------------------- | ----------- | ------------ |
| `postgres/` | `postgres`         | `postgres`  | 5432         |
| `redis/`    | `redis`            | `redis`     | 6379         |
| `minio/`    | `minio`            | `minio`     | 9000, 9001   |
| `mailpit/`  | `mailpit`          | `mailpit`   | 1025, 8025   |
| `mysql/`    | `mysql`            | `mysql`     | 3306         |

There is **no** single root `docker-compose.yml` – everything is split by folder on purpose.

## Per-service quick start

```bash
cd development/postgres
cp .env.example .env
docker compose up -d
```

Repeat for `redis/`, `minio/`, `mailpit/`, `mysql/` as needed.

## Docker Desktop

- Open **Containers** – you’ll see one group per project (`postgres`, `redis`, …).
- Start/stop/restart each stack without touching the others.
- Optional: **File → Open Folder** on each service folder if you use Desktop to run Compose from the UI.

## Run all stacks (bash)

From the `development` folder:

```bash
./dev-stacks.sh up      # start all (copies .env.example → .env if needed)
./dev-stacks.sh down    # stop all
./dev-stacks.sh status  # ps for each stack
```

## Connection reference

- **Postgres:** `postgresql://postgres:PASSWORD@localhost:5432/postgres` – create DBs when needed.
- **Redis:** `redis://:REDIS_PASSWORD@localhost:6379/0`
- **MinIO:** `http://localhost:9000` – credentials in `minio/.env`
- **Mailpit UI:** http://localhost:8025 – SMTP `localhost:1025`
- **MySQL:** `root` on `localhost:3306` – image **mysql:8.4** (default **caching_sha2_password**). Clients must support it or use TLS. If init fails or you switched from 8.0, wipe `mysql/data` then `docker compose up -d` again.

## Layout

```
development/
├── dev-stacks.sh         # bash: up / down / status for all stacks
├── .env.example          # optional: all vars in one place (copy into each folder if you prefer)
├── README.md
├── postgres/
│   ├── docker-compose.yml
│   ├── .env.example
│   └── data/             # gitignored
├── redis/
│   ├── docker-compose.yml
│   ├── .env.example
│   └── data/
├── minio/
│   ├── docker-compose.yml
│   ├── .env.example
│   └── data/
├── mailpit/
│   ├── docker-compose.yml
│   ├── .env.example
│   └── data/             # gitignored (SQLite inbox)
└── mysql/
    ├── docker-compose.yml
    ├── .env.example
    └── data/
```

Stop a single stack:

```bash
cd development/postgres
docker compose down
```

## Mailpit: port 1025 already allocated

If `docker compose up` fails with **port is already allocated** on **1025** (or **8025**):

1. **Free the port** – often an old Mailhog/Mailpit container still bound:
   ```bash
   docker ps -a | grep -E '1025|mailhog|mailpit'
   docker stop mailhog 2>/dev/null; docker rm mailhog 2>/dev/null
   # or remove whatever container publishes 1025
   ```
2. **Or use different host ports** – edit `mailpit/.env`:
   ```bash
   MAILPIT_SMTP_PORT=1026
   MAILPIT_UI_PORT=8026
   ```
   Then set your app SMTP host to `localhost` and port **1026**; open the UI at http://localhost:8026

## Git

Clone on another machine:

```bash
git clone https://github.com/marloxxx/local-dev-stacks.git
cd local-dev-stacks
# copy .env.example → .env per service, then docker compose up -d
```

`.env` and all `**/data/` directories are ignored – only compose files and `.env.example` are tracked.
