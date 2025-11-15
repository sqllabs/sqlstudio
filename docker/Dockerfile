FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    GOROOT="/data/go" \
    GOPATH="/data/go-workspace" \
    GOPROXY="https://proxy.golang.org,direct" \
    PATH="/data/go/bin:$PATH"

COPY vimrc \
     mysqlstudio.http.conf \
     nginx.conf \
     config.toml \
     settings.py \
     initialize.sh /root/

RUN apt update && \
    apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" upgrade && \
    apt install -y lsb-release && \
    apt install -y curl && \
    apt install -y vim && \
    apt install -y gosu && \
    apt install -y iftop && \
    apt install -y mtr && \
    apt install -y netcat-openbsd && \
    apt install -y net-tools && \
    apt install -y iputils-ping && \
    apt install -y httping && \
    apt install -y jq && \
    apt install -y tree && \
    apt install -y lrzsz && \
    mv /etc/vim/vimrc /etc/vim/vimrc.$(date +"%Y%m%d%H%M%S") && \
    mv /root/vimrc /etc/vim/vimrc && \
    chmod 644 /etc/vim/vimrc && \
    rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    mkdir -p /data/ && \
    groupadd -g 10000 nginx && \
    useradd -u 10000 -g 10000 -m -d /data/nginx -r -s /usr/sbin/nologin -c "Added by administrator. Please do not delete." nginx && \
    apt install -y wget && \
    apt install -y gnupg2 && \
    apt install -y ca-certificates && \
    wget -O - https://openresty.org/package/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/openresty.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/openresty.list > /dev/null && \
    apt update && \
    apt install -y openresty && \
    mkdir -p /usr/local/openresty/nginx/conf.d && \
    mkdir -p /usr/local/openresty/nginx/logs && \
    mkdir -p /usr/local/openresty/nginx/ssl && \
    mv /usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf.$(date +"%Y%m%d%H%M%S") && \
    mv /root/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf && \
    chmod 644 /usr/local/openresty/nginx/conf/nginx.conf && \
    mv /root/mysqlstudio.http.conf /usr/local/openresty/nginx/conf.d/ && \
    chmod 644 /usr/local/openresty/nginx/conf.d/mysqlstudio.http.conf && \
    mkdir -p /usr/local/openresty/nginx/client_body_temp && \
    mkdir -p /usr/local/openresty/nginx/fastcgi_temp && \
    mkdir -p /usr/local/openresty/nginx/proxy_temp && \
    mkdir -p /usr/local/openresty/nginx/scgi_temp && \
    mkdir -p /usr/local/openresty/nginx/uwsgi_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx/client_body_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx/fastcgi_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx/proxy_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx/scgi_temp && \
    chown -R nginx:nginx /usr/local/openresty/nginx/uwsgi_temp && \
    curl -C - -fsSLo ./mysql-apt-config_0.8.36-1_all.deb https://dev.mysql.com/get/mysql-apt-config_0.8.36-1_all.deb && \
    echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.4-lts" | debconf-set-selections && \
    echo "mysql-apt-config mysql-apt-config/select-product select select Ok" | debconf-set-selections && \
    echo "mysql-community-server mysql-community-server/root-pass password MySQLStudio1.13.1" | debconf-set-selections && \
    echo "mysql-community-server mysql-community-server/re-root-pass password MySQLStudio1.13.1" | debconf-set-selections && \
    echo "mysql-community-server mysql-community-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections && \
    dpkg -i mysql-apt-config_0.8.36-1_all.deb && \
    rm -f mysql-apt-config_0.8.36-1_all.deb && \
    apt update && \
    apt install -y mysql-community-server && \
    apt install -y mysql-community-client && \
    apt install -y libmysqlclient-dev && \
    /usr/bin/bash /root/initialize.sh db && \
    echo "default-character-set = utf8mb4" >> /etc/mysql/conf.d/mysql.cnf && \
    echo "port = 3306" >> /etc/mysql/conf.d/mysql.cnf && \
    echo "[client]" >> /etc/mysql/conf.d/mysql.cnf && \
    echo "default-character-set = utf8mb4" >> /etc/mysql/conf.d/mysql.cnf && \
    echo "port = 3306" >> /etc/mysql/conf.d/mysql.cnf && \
    sed -i '/\/var\/log\/mysql\/error\.log/d' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Basic Server Configuration" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Parameters related to the basic operation of the server." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "port                                         = 3306" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "bind-address                                 = 0.0.0.0" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "server_id                                    = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Character Set and Time Zone" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Ensures the database uses the correct character set and time zone settings." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "character-set-server                         = utf8mb4" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "collation-server                             = utf8mb4_bin" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "default-time-zone                            = '+00:00'" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Connection and User Management" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Parameters for managing client connections and user sessions." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "max_connections                              = 100" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "max_allowed_packet                           = 64M" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "wait_timeout                                 = 600" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "interactive_timeout                          = 600" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "thread_cache_size                            = 100" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "init-connect                                 = 'SET NAMES utf8mb4'" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Security Configuration" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Settings related to security, such as authentication and password policies." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "authentication_policy                        = caching_sha2_password" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "local_infile                                 = OFF" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "log_bin_trust_function_creators              = OFF" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "validate_password.policy                     = MEDIUM" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "validate_password.length                     = 8" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "validate_password.number_count               = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "validate_password.mixed_case_count           = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "validate_password.special_char_count         = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "default_password_lifetime                    = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "ssl-ca                                       = /var/lib/mysql/ca.pem" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "ssl-cert                                     = /var/lib/mysql/server-cert.pem" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "ssl-key                                      = /var/lib/mysql/server-key.pem" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "require_secure_transport                     = OFF" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "tls_version                                  = TLSv1.2,TLSv1.3" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# InnoDB Engine Configuration" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Optimizes the performance and behavior of the InnoDB storage engine." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_buffer_pool_size                      = 4G" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_buffer_pool_instances                 = 4" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_redo_log_capacity                     = 512M" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_log_buffer_size                       = 16M" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_flush_log_at_trx_commit               = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_flush_method                          = O_DIRECT" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_flush_neighbors                       = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_file_per_table                        = ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_io_capacity                           = 2000" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_io_capacity_max                       = 4000" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_thread_concurrency                    = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_write_io_threads                      = 8" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "innodb_read_io_threads                       = 8" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "default_table_encryption                     = OFF" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Query and Transaction Optimization" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Configurations to improve query performance and transaction handling." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "transaction_isolation                        = REPEATABLE-READ" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "optimizer_switch                             = 'mrr=on,mrr_cost_based=off,batched_key_access=on'" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "tmp_table_size                               = 128M" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "max_heap_table_size                          = 128M" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "sort_buffer_size                             = 4M" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "temptable_max_ram                            = 1G" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Logging and Monitoring" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Configures logging and performance monitoring." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "general_log                                  = OFF" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "general_log_file                             = /var/log/mysql/mysql-general.log" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "log-error                                    = /var/log/mysql/mysql-error.log" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "slow_query_log                               = ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "slow_query_log_file                          = /var/log/mysql/mysql-slow.log" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "long_query_time                              = 0.3" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "log_timestamps                               = UTC" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "performance_schema                           = ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Binary Logging and Replication" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Parameters related to data replication and recovery." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "log_bin                                      = /var/log/mysql/mysql-bin.log" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "binlog_expire_logs_seconds                   = 604800" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "sync_binlog                                  = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "gtid_mode                                    = ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "enforce_gtid_consistency                     = ON" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Miscellaneous Configuration" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# Miscellaneous settings not covered in the above categories." >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "table_open_cache                             = 4000" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "tmpdir                                       = /tmp" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "open_files_limit                             = 65535" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "sql_mode                                     = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "# skip-grant-tables" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    curl -C - -fsSLo ./percona-release_latest.$(lsb_release -sc)_all.deb https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb && \
    dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb && \
    apt update && \
    rm -f percona-release_latest.$(lsb_release -sc)_all.deb && \
    percona-release enable-only tools && \
    apt update && \
    apt install -y percona-xtrabackup-84 && \
    apt install -y percona-toolkit && \
    curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
    chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/redis.list && \
    touch /etc/apt/preferences.d/redis && \
    echo "Package: *" >> /etc/apt/preferences.d/redis && \
    echo "Pin: origin packages.redis.io" >> /etc/apt/preferences.d/redis && \
    echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/redis && \
    apt update && \
    apt install -y redis && \
    apt install -y redis-server && \
    apt install -y redis-tools && \
    sed -i "s/appendonly no/appendonly yes/g" /etc/redis/redis.conf && \
    sed -i "s/bind 127.0.0.1 -::1/bind 0.0.0.0/g" /etc/redis/redis.conf && \
    sed -i "s/# requirepass foobared/requirepass MySQLStudio1.13.1/g" /etc/redis/redis.conf && \
    echo "# rename-command CONFIG \"sss-config\"" >> /etc/redis/redis.conf && \
    echo "# rename-command EVAL \"sss-eval\"" >> /etc/redis/redis.conf && \
    echo "# rename-command FLUSHALL \"sss-flushall\"" >> /etc/redis/redis.conf && \
    echo "# rename-command FLUSHDB \"sss-flushdb\"" >> /etc/redis/redis.conf && \
    echo "# rename-command KEYS \"sss-keys\"" >> /etc/redis/redis.conf && \
    usermod -u 16379 redis && \
    groupmod -g 16379 redis && \
    mkdir -p /var/run/redis && \
    chown -R redis:redis /etc/redis && \
    chown -R redis:redis /var/lib/redis && \
    chown -R redis:redis /var/log/redis && \
    chown -R redis:redis /var/run/redis && \
    curl -C - -fsSLo /data/go1.25.4.linux-amd64.tar.gz https://go.dev/dl/go1.25.4.linux-amd64.tar.gz && \
    tar -xf /data/go1.25.4.linux-amd64.tar.gz -C /data/ && \
    mkdir -p /data/go-workspace && \
    chown -R root:root /data/go && \
    chown -R root:root /data/go-workspace && \
    chmod 755 /data/go && \
    chmod 755 /data/go-workspace && \
    apt install -y git && \
    git clone -b develop https://github.com/sqllabs/mysqlbinlog.git /data/mysqlbinlog && \
    cd /data/mysqlbinlog && \
    /data/go/bin/go build -o mysqlbinlog . && \
    chmod +x /data/mysqlbinlog/mysqlbinlog && \
    git clone -b develop https://github.com/sqllabs/mysqlaudit.git /data/mysqlaudit && \
    cd /data/mysqlaudit && \
    git config --add safe.directory /data/mysqlaudit && \
    /data/go/bin/go build -o mysqlaudit tidb-server/main.go && \
    chmod +x /data/mysqlaudit/mysqlaudit && \
    mv /root/config.toml /data/mysqlaudit/config/config.toml && \
    mkdir -p /data/mysqlaudit/tidb && \
    mkdir -p /data/mysqlaudit/logs && \
    apt install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt update && \
    apt install -y python3.13 && \
    apt install -y python3.13-dev && \
    apt install -y pkg-config && \
    apt install -y libkrb5-dev && \
    apt install -y gcc && \
    apt install -y libldap2-dev && \
    apt install -y libsasl2-dev && \
    apt install -y zlib1g-dev && \
    apt install -y unixodbc-dev && \
    curl -C - -fsSLo /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python3.13 /tmp/get-pip.py && \
    export MYSQLCLIENT_CFLAGS=$(mysql_config --cflags) && \
    export MYSQLCLIENT_LDFLAGS=$(mysql_config --libs) && \
    git clone -b develop https://github.com/sqllabs/mysqlstudio.git /data/mysqlstudio && \
    cp /data/mysqlstudio/archery/settings.py /data/mysqlstudio/archery/settings.py.$(date +"%Y%m%d%H%M%S") && \
    mv /root/settings.py /data/mysqlstudio/archery/settings.py && \
    sed -i 's|SECRET_KEY=(str, "[^"]*"),|SECRET_KEY=(str, "'"$(openssl rand -base64 32)"'"),|g' /data/mysqlstudio/archery/settings.py && \
    sed -i "s|172.18.0.31|localhost|g" /data/mysqlstudio/archery/settings.py && \
    cd /data/mysqlstudio && \
    python3.13 -m pip install --upgrade pip setuptools wheel && \
    python3.13 -m pip install -r requirements.txt && \
    python3.13 -m pip install --upgrade archery && \
    python3.13 -m pip install --upgrade redis && \
    python3.13 manage.py collectstatic --noinput --verbosity 3 && \
    /usr/bin/bash /root/initialize.sh mysqlstudio && \
    sed -i "s|localhost|172.18.0.31|g" /data/mysqlstudio/archery/settings.py && \
    usermod -u 13306 mysql && \
    groupmod -g 13306 mysql && \
    chown -R mysql:mysql /etc/mysql && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld && \
    cd /data/mysqlbinlog && \
    /data/go/bin/go clean -cache -modcache && \
    cd /data/mysqlaudit && \
    /data/go/bin/go clean -cache -modcache && \
    chown -R nginx:nginx /data/mysqlbinlog && \
    chmod 700 /data/mysqlbinlog && \
    chown -R nginx:nginx /data/mysqlaudit && \
    chmod 700 /data/mysqlaudit && \
    chown -R nginx:nginx /data/mysqlstudio && \
    chmod 700 /data/mysqlstudio && \
    rm -f /root/mysql-apt-config_0.8.36-1_all.deb && \
    rm -f /root/percona-release_latest.generic_all.deb && \
    rm -f /data/nginx/.bashrc && \
    rm -f /data/nginx/.bash_logout && \
    rm -f /data/nginx/.profile && \
    rm -f /tmp/get-pip.py && \
    rm -rf /data/*.tar.* && \
    rm -rf /data/go && \
    rm -rf /data/go-workspace && \
    rm -rf /data/mysqlbinlog/.git && \
    rm -rf /data/mysqlaudit/.git && \
    rm -rf /data/mysqlstudio/.git && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/* && \
    rm -rf /root/go && \
    rm -rf /root/.cache && \
    rm -f /root/initialize.sh && \
    rm -f /root/.wget-hsts*
