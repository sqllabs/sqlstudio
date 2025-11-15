# MySQL Studio Deployment

Transparent, containerized MySQL Studio deployment with independent components.

## Architecture

- Each MySQL Studio component runs in a separate container
- All data stored on host under `/data/`
- All configurations mounted as volumes
- Fixed UID/GID for easy migration

## Quick Start

```bash
bash install.sh
```

## Post-Installation

1. Update domain configuration:
   - Replace `server_name _` with your actual domain in:
     - `/usr/local/openresty/nginx/conf.d/mysqlstudio.http.conf`
   - Replace `mysqlstudio.example.com` with your actual domain in:
     - `/data/mysqlstudio/archery/settings.py`
2. Configure TLS certificate:
   - Place certificate files in `/usr/local/openresty/nginx/ssl/`
   - Uncomment TLS configuration in `/usr/local/openresty/nginx/conf.d/mysqlstudio.http.conf`
   - Comment out `listen 0.0.0.0:80`
   - Uncomment `listen 0.0.0.0:443 ssl` and `http2 on;`

3. Restart service:
   ```bash
   sudo systemctl restart openresty
   ```

## Directory Structure

```
/data/
├── mysqlstudio/      # MySQL Studio application data
├── mysqlaudit/       # MySQL Audit application data
├── mysqlbinlog/      # MySQL BinLog application data
├── mysql/            # MySQL data and configs
├── redis/            # Redis data and configs
└── nginx/            # Nginx logs and configs (optional)
```

## Maintenance

**View logs:**
```bash
docker logs mysqlstudio-<version>-server
docker logs mysqlstudio-<version>-qcluster
```

**Restart specific component:**
```bash
docker compose restart mysqlstudio-<version>-server
```

**Stop all:**
```bash
docker compose down
```

## Upgrade

**Automated version upgrade:**

The `upgrade.sh` script automatically checks and updates all components to their latest versions.

```bash
# Check for available updates and upgrade if needed
bash upgrade.sh
```

**What it does:**
- Fetches latest versions from official sources
- Compares with current versions in VERSION file
- If MySQL Studio version changed:
  - Backs up docker-compose.yml
  - Updates all component versions
  - Rebuilds Docker image
  - Migrates database

**Note:** The script only upgrades when MySQL Studio version changes. Component versions are locked to ensure compatibility.

## Migration

1. Create users on new server:
   ```bash
   sudo groupadd -g 10000 nginx && sudo useradd -u 10000 -g 10000 -m -d /data/nginx -r -s /usr/sbin/nologin nginx
   sudo groupadd -g 13306 mysql && sudo useradd -u 13306 -g 13306 -m -d /data/mysql -r -s /usr/sbin/nologin mysql
   sudo groupadd -g 16379 redis && sudo useradd -u 16379 -g 16379 -m -d /data/redis -r -s /usr/sbin/nologin redis
   ```

2. Rsync `/data/` directory from old server:
   ```bash
   rsync -av --progress /data/ user@new-server:/data/
   ```

3. Start containers:
   ```bash
   docker compose up -d
   ```

## Default Credentials

**MySQL Studio:**
- Username: `admin`
- Password: `MySQLStudio<version>`
