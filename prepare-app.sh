#!/usr/bin/env bash
set -e

echo "Building web image..."
docker build -t notesapp-web:latest ./web

echo "Creating network: notesapp-net"
docker network inspect notesapp-net >/dev/null 2>&1 || docker network create notesapp-net

echo "Creating volume: notesapp_db_data"
docker volume inspect notesapp_db_data >/dev/null 2>&1 || docker volume create notesapp_db_data

echo "Pulling database image: postgres:16-alpine"
docker pull postgres:16-alpine

echo "Done. Run ./start-app.sh to launch the app."
