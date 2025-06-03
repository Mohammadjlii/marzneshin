#!/bin/bash

sudo apt-get update && sudo apt-get install -y curl docker-compose git && \
sudo bash -c "$(curl -sL https://github.com/marzneshin/Marzneshin/raw/master/script.sh)" @ install


echo "Waiting 10 Sec"
sleep 10
echo "Done"

# تعریف مسیرها
DIR1="/var/lib/marzneshin/routes"
DIR2="/var/lib/marzneshin/subscription"
DIR3="/var/lib/marzneshin/templates"
DIR4="/var/lib/marzneshin/utils"
DIR5="/var/lib/marzneshin/certs"
DIR6="/var/lib/marzneshin/templates/subscription"
# ...
rm -rf "$DIR1"
rm -rf "$DIR2"
rm -rf "$DIR3"
rm -rf "$DIR4"
rm -rf "$DIR5"
rm -rf "$DIR6"

mkdir -p "$DIR1" "$DIR2" "$DIR3" "$DIR4" "$DIR5" "$DIR6"

curl -L -o "$DIR1/subscription.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/routes/subscription.py"
curl -L -o "$DIR2/index.html" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/templates/subscription/index.html"
curl -L -o "$DIR4/share.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils/share.py"
curl -L -o "$DIR4/faker.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils/faker.py"
curl -L -o "$DIR4/auth.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils/auth.py"
curl -L -o "$DIR4/crypto.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils/crypto.py"
curl -L -o "$DIR4/keygen.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils/keygen.py"
curl -L -o "$DIR4/system.py" "https://raw.githubusercontent.com/Mohammadjlii/marzneshin/master/app/utils/system.py"

# ...

echo "All folders created and files downloaded successfully."

echo "Waiting 5 Sec"
sleep 5
echo "Done"

#Install .env


ENV_PATH="/etc/opt/marzneshin/.env"

# حذف فایل قبلی اگر وجود دارد
if [ -f "$ENV_PATH" ]; then
    rm "$ENV_PATH"
    echo -e "\e[32mDnv file removed removed.\e[0m"
fi

# ساخت فایل جدید env
cat << EOF > "$ENV_PATH"

UVICORN_HOST = "0.0.0.0"
UVICORN_PORT = 2096

## THE FOLLOWING TWO VARIABLES ARE NOT SUPPORTED ANYMORE, USE merzneshin cli.
 SUDO_USERNAME = "Mohammad"
 SUDO_PASSWORD = "Mohammad381169@!"

 DASHBOARD_PATH = "/Ragacloud/"

# UVICORN_UDS: "/run/marzneshin.socket"
 UVICORN_SSL_CERTFILE = "/var/lib/marzneshin/certs/cert.crt"
 UVICORN_SSL_KEYFILE = "/var/lib/marzneshin/certs/private.key"


# SUBSCRIPTION_URL_PREFIX = "https://example.com"


# TELEGRAM_API_TOKEN = 123456789:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
# TELEGRAM_ADMIN_ID = 987654321, 123456789
# TELEGRAM_LOGGER_CHANNEL_ID = -1234567890123
# TELEGRAM_PROXY_URL = "http://localhost:8080"

# DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/xxxxxxx"

 CUSTOM_TEMPLATES_DIRECTORY="/var/lib/marzneshin/templates/"
# CLASH_SUBSCRIPTION_TEMPLATE="/var/lib/marzneshin/templates/clash.yml"
# SINGBOX_SUBSCRIPTION_TEMPLATE="/var/lib/marzneshin/templates/sing-box.json"
 XRAY_SUBSCRIPTION_TEMPLATE="/var/lib/marzneshin/templates/xray.json"
 SUBSCRIPTION_PAGE_TEMPLATE="subscription/index.html"
# HOME_PAGE_TEMPLATE="home/index.html"

# SQLALCHEMY_DATABASE_URL = "sqlite:///db.sqlite3"
# SQLALCHEMY_CONNECTION_POOL_SIZE = 10
# SQLALCHEMY_CONNECTION_MAX_OVERFLOW = -1

### for developers
# DOCS=true
# DEBUG=true
# WEBHOOK_ADDRESS = "http://127.0.0.1:9000/"
# WEBHOOK_SECRET = "something-very-very-secret"
# VITE_BASE_API="https://example.com/api/"
# JWT_ACCESS_TOKEN_EXPIRE_MINUTES = 1440
# AUTH_GENERATION_ALGORITHM=xxh128

## Scheduled Tasks Interval in Seconds
# TASKS_RECORD_USER_USAGES_INTERVAL=30
# TASKS_REVIEW_USERS_INTERVAL=30
# TASKS_EXPIRE_DAYS_REACHED_INTERVAL=30
# TASKS_RESET_USER_DATA_USAGE=3600

EOF

echo -e "\e[32mNew env created successfully.\e[0m"

echo "Waiting 5 Sec"
sleep 5
echo "Done"

# install docker-compose

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
     - /var/lib/marzneshin:/var/lib/marzneshin
     - /var/lib/marzneshin/utils:/app/app/utils
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

echo "Waiting 5 Sec"
sleep 5
echo "Done"

# ری‌استارت کردن سرویس marzneshin با docker-compose

docker-compose -f /etc/opt/marzneshin/docker-compose.yml down
docker-compose -f /etc/opt/marzneshin/docker-compose.yml up -d

if [ $? -eq 0 ]; then
  echo -e "\e[32mdocker-compose restarted marzneshin successfully.\e[0m"
else
  echo -e "\e[31mFailed to restart marzneshin docker-compose.\e[0m"
fi
