#!/bin/bash

# تعریف مسیرها
DIR1="/var/lib/marzneshin/routes"
DIR2="/var/lib/marzneshin/subscription"
DIR3="/var/lib/marzneshin/templates"
DIR4="/var/lib/marzneshin/utils"
DIR5="/var/lib/marzneshin/certs"
# ...

rm -rf -p "$DIR1"
rm -rf -p "$DIR2"
rm -rf -p "$DIR3"
rm -rf -p "$DIR4"
rm -rf -p "$DIR5"

# ساخت پوشه‌ها
mkdir -p "$DIR1"
mkdir -p "$DIR2"
mkdir -p "$DIR3"
mkdir -p "$DIR4"
mkdir -p "$DIR5"
# ...

# دانلود فایل‌ها و قرار دادن در مسیر مشخص
curl -L -o "$DIR1/subscription.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/routes"
curl -L -o "$DIR2/index.html" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/templates/subscription"
curl -L -o "$DIR3/share.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils"
curl -L -o "$DIR4/faker.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils"
# ...

echo "All folders created and files downloaded successfully."

COMPOSE_PATH="/etc/opt/marzneshin/docker-compose.yml"

# حذف فایل قبلی اگر وجود دارد
if [ -f "$COMPOSE_PATH" ]; then
    rm "$COMPOSE_PATH"
    echo -e "\e[32mOld docker-compose.yml removed.\e[0m"
fi

# ساخت فایل جدید docker-compose.yml
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
marzneshin restart

if [ $? -eq 0 ]; then
  echo -e "\e[32mdocker-compose restarted marzneshin successfully.\e[0m"
else
  echo -e "\e[31mFailed to restart marzneshin docker-compose.\e[0m"
fi
