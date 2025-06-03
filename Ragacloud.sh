#!/bin/bash

COMPOSE_FILE="docker-compose.yml"

# تغییر volumes سرویس marzneshin
yq eval '.services.marzneshin.volumes = [
  "/home/youruser/marzneshin/utils:/app/app/utils",
  "/home/youruser/marzneshin/routes:/app/app/routes",
  "/var/lib/marzneshin/certs:/var/lib/marzneshin/certs",
  "/var/lib/marzneshin/db.sqlite3:/var/lib/marzneshin/db.sqlite3"
]' -i $COMPOSE_FILE

echo "docker-compose.yml updated successfully!"