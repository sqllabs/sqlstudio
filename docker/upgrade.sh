#!/usr/bin/env bash

NEW_MYSQL_STUDIO_VERSION="$(curl -sSL https://api.github.com/repos/sqllabs/mysqlstudio/releases/latest 2>/dev/null | jq -r .tag_name | sed 's/^v//')"
NEW_MYSQL_AUDIT_VERSION="$(curl -sSL https://api.github.com/repos/sqllabs/mysqlaudit/releases/latest 2>/dev/null | jq -r .tag_name | sed 's/^v//')"
NEW_GO_VERSION="$(curl -sSL https://go.dev/dl/ 2>/dev/null | grep -oP 'go\K[0-9]+\.[0-9]+\.[0-9]+(?=\.linux-amd64\.tar\.gz)' | sort -Vr | head -1)"
NEW_MYSQL_VERSION="$(curl -sSL https://dev.mysql.com/doc/relnotes/mysql/8.4/en/ 2>/dev/null | grep -oP 'Changes in MySQL \K8\.4\.[0-9]+' | sort -Vr | uniq | head -n 1)"
NEW_REDIS_VERSION="$(curl -sSL https://download.redis.io/releases/ 2>/dev/null | grep -oP 'redis-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | sort -Vr | head -n 1)"

if [[ -z "$NEW_MYSQL_STUDIO_VERSION" || ! "$NEW_MYSQL_STUDIO_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to get the latest version of MySQL Studio or the version format is invalid: $NEW_MYSQL_STUDIO_VERSION"
    exit 1
fi

if [[ -z "$NEW_MYSQL_AUDIT_VERSION" || ! "$NEW_MYSQL_AUDIT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to get the latest version of SQL Audit or the version format is invalid: $NEW_MYSQL_AUDIT_VERSION"
    exit 1
fi

if [[ -z "$NEW_GO_VERSION" || ! "$NEW_GO_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to get the latest version of Go or the version format is invalid: $NEW_GO_VERSION"
    exit 1
fi

if [[ -z "$NEW_MYSQL_VERSION" || ! "$NEW_MYSQL_VERSION" =~ ^8\.4\.[0-9]+$ ]]; then
    echo "Failed to get the latest version of MySQL or the version format is invalid: $NEW_MYSQL_VERSION"
    exit 1
fi

if [[ -z "$NEW_REDIS_VERSION" || ! "$NEW_REDIS_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to get the latest version of Redis or the version format is invalid: $NEW_REDIS_VERSION"
    exit 1
fi

if [[ ! -f VERSION ]]; then
    echo "VERSION: No such file or directory"
    exit 1
fi

OLD_MYSQL_STUDIO_VERSION="$(grep -oP 'OLD_MYSQL_STUDIO_VERSION=\K[0-9]+\.[0-9]+\.[0-9]+' VERSION)"
OLD_MYSQL_AUDIT_VERSION="$(grep -oP 'OLD_MYSQL_AUDIT_VERSION=\K[0-9]+\.[0-9]+\.[0-9]+' VERSION)"
OLD_GO_VERSION="$(grep -oP 'OLD_GO_VERSION=\K[0-9]+\.[0-9]+\.[0-9]+' VERSION)"
OLD_MYSQL_VERSION="$(grep -oP 'OLD_MYSQL_VERSION=\K8\.4\.[0-9]+' VERSION)"
OLD_REDIS_VERSION="$(grep -oP 'OLD_REDIS_VERSION=\K[0-9]+\.[0-9]+\.[0-9]+' VERSION)"

if [[ -z "$OLD_MYSQL_STUDIO_VERSION" || ! "$OLD_MYSQL_STUDIO_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to get the old version of MySQL Studio or the version format is invalid: $OLD_MYSQL_STUDIO_VERSION"
    exit 1
fi

if [[ -z "$OLD_MYSQL_AUDIT_VERSION" || ! "$OLD_MYSQL_AUDIT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to get the old version of SQL Audit or the version format is invalid: $OLD_MYSQL_AUDIT_VERSION"
    exit 1
fi

if [[ -z "$OLD_GO_VERSION" || ! "$OLD_GO_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to get the old version of Go or the version format is invalid: $OLD_GO_VERSION"
    exit 1
fi

if [[ -z "$OLD_MYSQL_VERSION" || ! "$OLD_MYSQL_VERSION" =~ ^8\.4\.[0-9]+$ ]]; then
    echo "Failed to get the old version of MySQL or the version format is invalid: $OLD_MYSQL_VERSION"
    exit 1
fi

if [[ -z "$OLD_REDIS_VERSION" || ! "$OLD_REDIS_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to get the old version of Redis or the version format is invalid: $OLD_REDIS_VERSION"
    exit 1
fi

if [[ "$NEW_MYSQL_STUDIO_VERSION" != "$OLD_MYSQL_STUDIO_VERSION" ]]; then
    BACKUP_ID="$(cat /proc/sys/kernel/random/uuid)"
    cp docker-compose.yml "docker-compose.yml_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    cp Dockerfile "Dockerfile_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    cp VERSION "VERSION_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    cp install.sh "install.sh_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    cp config.toml "config.toml_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    cp initialize.sh "initialize.sh_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"

    # MySQL Studio
    sed -i "s/$OLD_MYSQL_STUDIO_VERSION/$NEW_MYSQL_STUDIO_VERSION/g" Dockerfile docker-compose.yml VERSION

    # SQL Audit
    sed -i "s/$OLD_MYSQL_AUDIT_VERSION/$NEW_MYSQL_AUDIT_VERSION/g" Dockerfile VERSION
    sed -i "s/$OLD_MYSQL_STUDIO_VERSION/$NEW_MYSQL_STUDIO_VERSION/g" config.toml

    # Go
    sed -i "s/$OLD_GO_VERSION/$NEW_GO_VERSION/g" Dockerfile VERSION

    # MySQL
    sed -i "s/$OLD_MYSQL_VERSION/$NEW_MYSQL_VERSION/g" VERSION

    # Redis
    sed -i "s/$OLD_REDIS_VERSION/$NEW_REDIS_VERSION/g" VERSION

    # install.sh
    sed -i "s/$OLD_MYSQL_STUDIO_VERSION/$NEW_MYSQL_STUDIO_VERSION/g" install.sh

    # initialize.sh
    sed -i "s/$OLD_MYSQL_STUDIO_VERSION/$NEW_MYSQL_STUDIO_VERSION/g" initialize.sh

    # settings.py
    sed -i "s/$OLD_MYSQL_STUDIO_VERSION/$NEW_MYSQL_STUDIO_VERSION/g" settings.py

    DOCKER_BUILDKIT=1 sudo docker build --progress=plain -t "mysqlstudio:$NEW_MYSQL_STUDIO_VERSION" -f Dockerfile .
    sudo docker create --name temp-container "mysqlstudio:$NEW_MYSQL_STUDIO_VERSION"
    sudo docker export -o "mysqlstudio-$NEW_MYSQL_STUDIO_VERSION.$(TZ=UTC date +"%Y%m%d").tar" temp-container
    sudo docker rm temp-container
    sudo docker rmi "mysqlstudio:$NEW_MYSQL_STUDIO_VERSION"
    sudo docker system prune -f
    sudo docker import "mysqlstudio-$NEW_MYSQL_STUDIO_VERSION.$(TZ=UTC date +"%Y%m%d").tar" "mysqlstudio:$NEW_MYSQL_STUDIO_VERSION"
    sudo rm -f "mysqlstudio-$NEW_MYSQL_STUDIO_VERSION.$(TZ=UTC date +"%Y%m%d").tar"
    sudo docker save -o "mysqlstudio-$NEW_MYSQL_STUDIO_VERSION.$(TZ=UTC date +"%Y%m%d").tar" "mysqlstudio:$NEW_MYSQL_STUDIO_VERSION"
    sudo chown $USER:$USER "mysqlstudio-$NEW_MYSQL_STUDIO_VERSION.$(TZ=UTC date +"%Y%m%d").tar"

    sudo docker compose -f "docker-compose.yml_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}" rm -s -f 
    sudo docker rmi "mysqlstudio:$OLD_MYSQL_STUDIO_VERSION"

    sudo rsync -av --progress /data/mysqlstudio "/data/mysqlstudio_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/mysqlaudit "/data/mysqlaudit_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/nginx/mysqlstudio_conf "/data/nginx/mysqlstudio_conf_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/nginx/mysqlstudio_conf.d "/data/nginx/mysqlstudio_conf.d_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/nginx/mysqlstudio_logs "/data/nginx/mysqlstudio_logs_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/mysql/mysqlstudio_conf "/data/mysql/mysqlstudio_conf_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/mysql/mysqlstudio_data "/data/mysql/mysqlstudio_data_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/mysql/mysqlstudio_log "/data/mysql/mysqlstudio_log_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/redis/mysqlstudio_conf "/data/redis/mysqlstudio_conf_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/redis/mysqlstudio_data "/data/redis/mysqlstudio_data_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"
    sudo rsync -av --progress /data/redis/mysqlstudio_log "/data/redis/mysqlstudio_log_${BACKUP_ID}_${OLD_MYSQL_STUDIO_VERSION}"

    sudo docker compose up -d
    sudo docker cp "mysqlstudio-$NEW_MYSQL_STUDIO_VERSION-server":/data/mysqlstudio/static/. /data/mysqlstudio/static
    sudo chown -R nginx:nginx /data/mysqlstudio

    echo "======================================"
    echo "Please follow the official upgrade guide to migrate your database:"
    echo "https://github.com/sqllabs/mysqlstudio/wiki/upgrade"
    echo "======================================"
else
    echo "MySQL Studio is already up to date"
fi
