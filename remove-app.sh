#!/usr/bin/env bash
set -e

read -p "This will permanently delete all app data. Continue? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

echo "Removing container: notesapp-web"
docker rm -f notesapp-web >/dev/null 2>&1 || true
echo "Removing container: notesapp-db"
docker rm -f notesapp-db >/dev/null 2>&1 || true
echo "Removing image: notesapp-web:latest"
docker rmi notesapp-web:latest >/dev/null 2>&1 || true
echo "Removing volume: notesapp_db_data"
docker volume rm notesapp_db_data >/dev/null 2>&1 || true
echo "Removing network: notesapp-net"
docker network rm notesapp-net >/dev/null 2>&1 || true

echo "Removed app."