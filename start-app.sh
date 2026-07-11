#!/usr/bin/env bash
set -e

echo "Running app..."

if [ "$(docker ps -aq -f name=^notesapp-db$)" ]; then
    echo "Starting existing container: notesapp-db"
    docker start notesapp-db >/dev/null
else
    echo "Creating container: notesapp-db"
    docker run -d \
        --name notesapp-db \
        --network notesapp-net \
        --restart unless-stopped \
        -e POSTGRES_DB=notesapp \
        -e POSTGRES_USER=notesapp \
        -e POSTGRES_PASSWORD=notesapp \
        -p 5432:5432 \
        -v notesapp_db_data:/var/lib/postgresql/data \
        postgres:16-alpine >/dev/null
fi

if [ "$(docker ps -aq -f name=^notesapp-web$)" ]; then
    echo "Starting existing container: notesapp-web"
    docker start notesapp-web >/dev/null
else
    echo "Creating container: notesapp-web"
    docker run -d \
        --name notesapp-web \
        --network notesapp-net \
        --restart unless-stopped \
        -e DB_HOST=notesapp-db \
        -e DB_PORT=5432 \
        -e DB_NAME=notesapp \
        -e DB_USER=notesapp \
        -e DB_PASSWORD=notesapp \
        -p 5000:5000 \
        notesapp-web:latest >/dev/null
fi

echo "Containers are up."
echo "The app is available at http://localhost:5000"