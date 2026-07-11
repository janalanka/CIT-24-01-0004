# Notes App — Docker Multi-Container Assignment

**CCS3308 - Virtualization and Containers**

**Registration Number:** CIT-24-01-0004
**Author:** [ඔයාගේ පූර්ණ නම මෙතන දාන්න]
**GitHub Repo:** https://github.com/[ඔයාගේ-username]/CIT-24-01-0004

## Application Description

A small Notes App: a web frontend where you can add and delete short text notes, backed by a
PostgreSQL database. It demonstrates a two-tier Docker deployment:

- **web** — a custom-built Flask application (Python) that serves the UI and talks to Postgres to
  read/write notes.
- **db** — the official `postgres:16-alpine` image, storing notes in a table on a persistent named
  volume.

The two containers communicate over a private Docker bridge network using Docker's built-in
DNS (the web container reaches the database simply by hostname `notesapp-db`).

## Deployment Requirements

- Docker Engine 24+ (tested with Docker Desktop)
- Bash shell (Git Bash on Windows, or Linux/macOS terminal) to run the `.sh` scripts
- Internet access on first run, to pull `postgres:16-alpine` and `python:3.12-slim`

## Network and Volume Details

| Resource | Name | Type | Purpose |
|---|---|---|---|
| Network | `notesapp-net` | Docker bridge network | Lets `notesapp-web` resolve and reach `notesapp-db` by container name; isolates app traffic from other Docker workloads on the host. |
| Volume | `notesapp_db_data` | Docker named volume | Mounted at `/var/lib/postgresql/data` inside `notesapp-db`. Persists all notes across stop/start cycles and container recreation; only deleted by `remove-app.sh`. |

## Container Configuration

| Setting | notesapp-db | notesapp-web |
|---|---|---|
| Image | `postgres:16-alpine` (official) | `notesapp-web:latest` (custom build from `./web/Dockerfile`) |
| Host port | 5432 -> 5432 | 5000 -> 5000 |
| Network | notesapp-net | notesapp-net |
| Volume | `notesapp_db_data:/var/lib/postgresql/data` | none |
| Restart policy | unless-stopped | unless-stopped |
| Config method | Environment variables: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` | Environment variables: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` |

Both containers are configured purely through environment variables passed at `docker run` time
(see `start-app.sh`), so credentials/config can be changed without rebuilding any image.

## Container List

| Container | Role |
|---|---|
| `notesapp-db` | PostgreSQL database storing notes; the stateful service. |
| `notesapp-web` | Flask web server; serves the UI on port 5000 and is the only service the user interacts with directly. |

## Files in This Repository

| File | Purpose |
|---|---|
| `prepare-app.sh` | Builds the notesapp-web image, creates the notesapp-net network and notesapp_db_data volume, pulls the Postgres image. |
| `start-app.sh` | Creates/starts both containers with the restart policy applied, prints the access URL. |
| `stop-app.sh` | Stops both containers without deleting them or their data. |
| `remove-app.sh` | Removes both containers, the custom image, the network, and the volume. |
| `docker-compose.yaml` | Optional Compose equivalent of the four scripts above. |
| `web/` | Flask application source, requirements.txt, and Dockerfile. |

## Instructions

### 1. Prepare
```bash
chmod +x prepare-app.sh start-app.sh stop-app.sh remove-app.sh
./prepare-app.sh
```
Builds the web image and creates the network/volume.

### 2. Run
```bash
./start-app.sh
```
Starts both containers (or restarts the existing ones, preserving data) and prints the URL to access the app.

### 3. Access the app
Open a web browser and go to: