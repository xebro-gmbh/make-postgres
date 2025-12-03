# Postgres Bundle

The Postgres bundle adds a PostgreSQL 17 instance for local development. It exposes Make helpers for shell access, restarts, and dumping/restoring databases. As with every module inside `docker/`, it relies on `docker/core` to publish its targets.

## Core Principles

- **Development scoped** – The Compose service (`postgres`) is configured for local debugging (default credentials, exposed port 5432). Do not reuse it for production workloads.
- **Core driven** – Targets such as `postgres.install` or `postgres.export` are executed through the global `Makefile` that lives in `docker/core/main_file`.
- **Idempotent config** – Environment variables required by the service are appended to `.env` when you run `make postgres.install`.

## Installation & Usage

```bash
make postgres.install   # add env vars and helper files
make start              # boot the Compose service alongside other bundles
```

The default credentials are driven via `.env` / `.env.local` entries such as:

```
POSTGRES_DB=symfony
POSTGRES_USER=app
POSTGRES_PASSWORD=app
DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?serverVersion=17&charset=utf8
```

Feel free to override them in `docker/etc/config.env` or `.env.local`.

## Key Targets

- `postgres.bash` – Start an interactive shell in the container.
- `postgres.console` – Drop into `psql` inside the running service.
- `postgres.logs` – Follow container logs.
- `postgres.restart` – Recreate just the Postgres container.
- `postgres.export` – Dump the current database into `${XO_MODULES_DIR}/var/<timestamp>.sql`.
- `postgres.install` – Called by `make install`; ensures environment variables are configured.

All commands are listed in `make help` once the bundle is present in `docker/`.
