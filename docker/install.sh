#!/usr/bin/env bash

sudo groupadd -g 10000 nginx
sudo useradd -u 10000 -g 10000 -m -d /data/nginx -r -s /usr/sbin/nologin -c "Added by administrator. Please do not delete." nginx
sudo groupadd -g 13306 mysql
sudo useradd -u 13306 -g 13306 -m -d /data/mysql -r -s /usr/sbin/nologin -c "Added by administrator. Please do not delete." mysql
sudo groupadd -g 16379 redis
sudo useradd -u 16379 -g 16379 -m -d /data/redis -r -s /usr/sbin/nologin -c "Added by administrator. Please do not delete." redis

sudo apt install -y --no-install-recommends wget gnupg ca-certificates lsb-release
wget -O - https://openresty.org/package/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/openresty.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null
sudo apt update
sudo apt install -y openresty

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt remove -y $pkg; done
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl restart docker

sudo usermod -aG docker $USER

DOCKER_BUILDKIT=1 sudo docker build --progress=plain -t mysqlstudio:1.13.1 -f Dockerfile .
sudo docker create --name temp-container mysqlstudio:1.13.1
sudo docker export -o "mysqlstudio-1.13.1.$(TZ=UTC date +"%Y%m%d").tar" temp-container
sudo docker rm temp-container
sudo docker rmi mysqlstudio:1.13.1
sudo docker system prune -f
sudo docker import "mysqlstudio-1.13.1.$(TZ=UTC date +"%Y%m%d").tar" mysqlstudio:1.13.1
sudo rm -f "mysqlstudio-1.13.1.$(TZ=UTC date +"%Y%m%d").tar"
sudo docker save -o "mysqlstudio-1.13.1.$(TZ=UTC date +"%Y%m%d").tar" mysqlstudio:1.13.1
sudo chown $USER:$USER "mysqlstudio-1.13.1.$(TZ=UTC date +"%Y%m%d").tar"

sudo docker create --name mysqlstudio -it mysqlstudio:1.13.1 sleep infinity
sudo docker start mysqlstudio

sudo -u mysql mkdir -p /data/mysql/mysqlstudio_conf
sudo -u mysql mkdir -p /data/mysql/mysqlstudio_data
sudo -u mysql mkdir -p /data/mysql/mysqlstudio_log
sudo docker cp mysqlstudio:/etc/mysql/. /data/mysql/mysqlstudio_conf
sudo docker cp mysqlstudio:/var/lib/mysql/. /data/mysql/mysqlstudio_data
sudo docker cp mysqlstudio:/var/log/mysql/. /data/mysql/mysqlstudio_log
sudo chown -R mysql:mysql /data/mysql/mysqlstudio_conf
sudo chown -R mysql:mysql /data/mysql/mysqlstudio_data
sudo chown -R mysql:mysql /data/mysql/mysqlstudio_log

sudo -u redis mkdir -p /data/redis/mysqlstudio_conf
sudo -u redis mkdir -p /data/redis/mysqlstudio_data
sudo -u redis mkdir -p /data/redis/mysqlstudio_log
sudo docker cp mysqlstudio:/etc/redis/. /data/redis/mysqlstudio_conf
sudo docker cp mysqlstudio:/var/lib/redis/. /data/redis/mysqlstudio_data
sudo docker cp mysqlstudio:/var/log/redis/. /data/redis/mysqlstudio_log
sudo chown -R redis:redis /data/redis/mysqlstudio_conf
sudo chown -R redis:redis /data/redis/mysqlstudio_data
sudo chown -R redis:redis /data/redis/mysqlstudio_log

sudo mkdir -p /data/mysqlstudio/static
sudo mkdir -p /data/mysqlstudio/logs
sudo mkdir -p /data/mysqlstudio/archery
sudo docker cp mysqlstudio:/data/mysqlstudio/static/. /data/mysqlstudio/static
sudo docker cp mysqlstudio:/data/mysqlstudio/logs/. /data/mysqlstudio/logs
sudo docker cp mysqlstudio:/data/mysqlstudio/archery/settings.py /data/mysqlstudio/archery/settings.py
sudo chown -R nginx:nginx /data/mysqlstudio

sudo sed -i 's|SECRET_KEY=(str, "[^"]*"),|SECRET_KEY=(str, "'"$(openssl rand -base64 32)"'"),|g' /data/mysqlstudio/archery/settings.py

sudo mkdir -p /data/mysqlaudit/config
sudo mkdir -p /data/mysqlaudit/tidb
sudo mkdir -p /data/mysqlaudit/logs
sudo docker cp mysqlstudio:/data/mysqlaudit/config/config.toml /data/mysqlaudit/config/config.toml
sudo docker cp mysqlstudio:/data/mysqlaudit/tidb/. /data/mysqlaudit/tidb
sudo docker cp mysqlstudio:/data/mysqlaudit/logs/. /data/mysqlaudit/logs
sudo chown -R nginx:nginx /data/mysqlaudit

sudo -u nginx mkdir -p /data/nginx/mysqlstudio_conf
sudo -u nginx mkdir -p /data/nginx/mysqlstudio_conf.d
sudo -u nginx mkdir -p /data/nginx/mysqlstudio_logs
sudo docker cp mysqlstudio:/usr/local/openresty/nginx/conf/nginx.conf /data/nginx/mysqlstudio_conf/nginx.conf
sudo docker cp mysqlstudio:/usr/local/openresty/nginx/conf.d/mysqlstudio.http.conf /data/nginx/mysqlstudio_conf.d/mysqlstudio.http.conf
sudo docker cp mysqlstudio:/usr/local/openresty/nginx/logs/. /data/nginx/mysqlstudio_logs
sudo chown -R nginx:nginx /data/nginx/mysqlstudio_conf
sudo chown -R nginx:nginx /data/nginx/mysqlstudio_conf.d
sudo chown -R nginx:nginx /data/nginx/mysqlstudio_logs

sudo mkdir -p /usr/local/openresty/nginx/conf.d
sudo mkdir -p /usr/local/openresty/nginx/logs
sudo mkdir -p /usr/local/openresty/nginx/ssl
sudo cp /usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf.bak
sudo docker cp mysqlstudio:/usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
sudo docker cp mysqlstudio:/usr/local/openresty/nginx/conf.d/mysqlstudio.http.conf /usr/local/openresty/nginx/conf.d/mysqlstudio.http.conf

sudo docker stop mysqlstudio
sudo docker rm mysqlstudio

sudo docker network create --driver bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 --ipv6=false oss

sudo docker compose up -d

echo "======================================"
echo "Installation completed! Next steps:"
echo "1. Update domain configuration:"
echo "   Replace server_name _ with your actual domain in the following files:"
echo "   - /usr/local/openresty/nginx/conf.d/mysqlstudio.http.conf"
echo "   Replace mysqlstudio.example.com with your actual domain in:"
echo "     /data/mysqlstudio/archery/settings.py"
echo "2. Configure TLS certificate:"
echo "   - Place certificate files in /usr/local/openresty/nginx/ssl/ directory"
echo "   - Uncomment TLS configuration in /usr/local/openresty/nginx/conf.d/mysqlstudio.http.conf"
echo "   - Change listen 80 to listen 443 ssl http2"
echo "3. Restart service: sudo systemctl restart openresty"
echo "======================================"
