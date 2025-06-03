#!/bin/bash

DIR1="/var/lib/marzneshin/routes"
DIR2="/var/lib/marzneshin/subscription"
DIR3="/var/lib/marzneshin/templates"
DIR4="/var/lib/marzneshin/utils"
DIR5="/var/lib/marzneshin/certs"

rm -rf "$DIR1"
rm -rf "$DIR2"
rm -rf "$DIR3"
rm -rf "$DIR4"
rm -rf "$DIR5"

mkdir -p "$DIR1"
mkdir -p "$DIR2"
mkdir -p "$DIR3"
mkdir -p "$DIR4"
mkdir -p "$DIR5"

curl -L -o "$DIR1/subscription.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/routes/subscription.py"
curl -L -o "$DIR2/index.html" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/templates/subscription/index.html"
curl -L -o "$DIR4/share.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils/share.py"
curl -L -o "$DIR4/faker.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils/faker.py"

COMPOSE_PATH="/etc/opt/marzneshin/docker-compose.yml"

if [ -f "$COMPOSE_PATH" ]; then
    rm "$COMPOSE_PATH"
    echo -e "\e[32mOld docker-compose.yml removed.\e[0m"
fi

cat << EOF > "$COMPOSE_PATH"
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
     - /var/lib/marzneshin/utils:/app/app/utils
     - /var/lib/marzneshin/routes:/app/app/routes

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

docker-compose -f /etc/opt/marzneshin/docker-compose.yml down
docker-compose -f /etc/opt/marzneshin/docker-compose.yml up -d

if [ $? -eq 0 ]; then
  echo -e "\e[32mdocker-compose restarted marzneshin successfully.\e[0m"
else
  echo -e "\e[31mFailed to restart marzneshin docker-compose.\e[0m"
fi
