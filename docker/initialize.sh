#!/usr/bin/env bash

db(){
    echo "Starting MySQL database..."
    gosu mysql /usr/sbin/mysqld > /dev/null 2>&1 &
    sleep 30

    mysql -uroot -pMySQLStudio1.13.1 -e "
        INSTALL COMPONENT 'file://component_validate_password';
        SELECT * FROM mysql.component;
    "
}

mysqlstudio(){
    mysql -uroot -pMySQLStudio1.13.1 -e "
        CREATE DATABASE mysqlstudio CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
        CREATE USER 'mysqlstudio'@'%' IDENTIFIED WITH caching_sha2_password BY 'MySQLStudio1.13.1';
        GRANT ALL PRIVILEGES ON mysqlstudio.* TO 'mysqlstudio'@'%';
        FLUSH PRIVILEGES;
        CREATE USER 'backup'@'%' IDENTIFIED WITH caching_sha2_password BY 'MySQLStudio1.13.1';
        GRANT ALL PRIVILEGES ON *.* TO 'backup'@'%';
        FLUSH PRIVILEGES;
    "

    export DJANGO_SUPERUSER_USERNAME=admin
    export DJANGO_SUPERUSER_PASSWORD=MySQLStudio1.13.1
    export DJANGO_SUPERUSER_EMAIL=administrator@example.com

    python3.13 manage.py makemigrations sql && \
    python3.13 manage.py migrate && \
    python3.13 manage.py dbshell < sql/fixtures/auth_group.sql && \
    python3.13 manage.py dbshell < src/init_sql/mysql_slow_query_review.sql && \
    python3.13 manage.py createsuperuser --noinput
}

case $1 in
    db) db;;
    mysqlstudio) mysqlstudio;;
esac
