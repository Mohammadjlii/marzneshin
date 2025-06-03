#!/bin/bash

COMPOSE_PATH="/etc/opt/marzneshin/docker-compose.yml"

# حذف فایل قبلی اگر وجود دارد
if [ -f "$COMPOSE_PATH" ]; then
    rm "$COMPOSE_PATH"
    echo -e "\e[32mOld docker-compose.yml removed.\e[0m"
fi

# ساخت فایل جدید docker-compose.yml
cat << EOF > "$COMPOSE_PATH"
version: "3.8"
services:
  marzneshin:
    image: dawsh/marzneshin:latest
    restart: always
    env_file: .env
    network_mode: host
    environment:
      SQLALCHEMY_DATABASE_URL: "sqlite:////var/lib/marzneshin/db.sqlite3"
    volumes:
     - /var/lib/marzneshin/:/var/lib/marzneshin/
     - /var/lib/marzneshin/utils/share.py:/app/app/utils/share.py
     - /var/lib/marzneshin/utils/faker.py:/app/app/utils/faker.py
     - /var/lib/marzneshin/routes/subscription.py:/app/app/routes/subscription.py

  marznode:
    image: dawsh/marznode:latest
    restart: always
    network_mode: host
    environment:
      SERVICE_ADDRESS: "127.0.0.1"
      INSECURE: "True"
      XRAY_EXECUTABLE_PATH: "/usr/local/bin/xray"
      XRAY_ASSETS_PATH: "/usr/local/lib/xray"
      XRAY_CONFIG_PATH: "/var/lib/marznode/xray_config.json"
      SSL_KEY_FILE: "./server.key"
      SSL_CERT_FILE: "./server.cert"
    volumes:
      - /var/lib/marznode:/var/lib/marznode
EOF

echo -e "\e[32mNew docker-compose.yml created successfully.\e[0m"

# ری‌استارت کردن سرویس marzneshin با docker-compose
cd /etc/opt/marzneshin || { echo "Failed to cd to /etc/opt/marzneshin"; exit 1; }
docker-compose down
docker-compose up -d

if [ $? -eq 0 ]; then
  echo -e "\e[32mdocker-compose restarted marzneshin successfully.\e[0m"
else
  echo -e "\e[31mFailed to restart marzneshin docker-compose.\e[0m"
fi
