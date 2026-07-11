#!/usr/bin/env bash
set -e

echo "Stopping app..."
echo "Stopping container: notesapp-web"
docker stop notesapp-web >/dev/null 2>&1 || true
echo "Stopping container: notesapp-db"
docker stop notesapp-db >/dev/null 2>&1 || true

echo "App stopped. Data preserved. Run ./start-app.sh to resume."