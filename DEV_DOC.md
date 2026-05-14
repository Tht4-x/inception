# Developer Documentation — Inception

## Project overview

Inception is a Docker-based infrastructure composed of three services
orchestrated with Docker Compose. Each service runs in a dedicated container
built from a custom Dockerfile based on Debian Bookworm.

inception/ ├── Makefile ├── README.md ├── USER_DOC.md ├── DEV_DOC.md ├── secrets/ ← never commit this │ ├── db_password.txt │ ├── db_root_password.txt │ ├── wp_admin_password.txt │ └── wp_user_password.txt └── srcs/ ├── .env ← never commit this ├── docker-compose.yml └── requirements/ ├── mariadb/ │ ├── Dockerfile │ ├── conf/ │ │ └── my.cnf │ └── tools/ │ └── init.sh ├── wordpress/ │ ├── Dockerfile │ ├── conf/ │ │ └── www.conf │ └── tools/ │ └── setup.sh └── nginx/ ├── Dockerfile ├── conf/ │ └── nginx.conf └── tools/ └── setup.sh


---

## Prerequisites

- A Virtual Machine running Debian Bookworm
- Docker installed
- Docker Compose installed
- make installed
- Git installed

```bash
# Install prerequisites on Debian
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 make git

# Add your user to the docker group (avoids using sudo)
sudo usermod -aG docker $USER

# Log out and back in for the group change to take effect
```

---

## Environment setup from scratch

### 1. Clone the repository

```bash
git clone <your_repo> inception
cd inception
```

### 2. Create the secrets files

These files are not in the repository for security reasons.
You must create them manually:

```bash
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_password.txt
echo "your_wp_user_password" > secrets/wp_user_password.txt
```

### 3. Create the .env file

```bash
nano srcs/.env
```

```env
DOMAIN_NAME=dancel.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_ROOT_HOST=localhost

WP_TITLE=Inception
WP_ADMIN_LOGIN=dancel_admin
WP_ADMIN_EMAIL=dancel@student.42.fr
WP_USER_LOGIN=dancel
WP_USER_EMAIL=dancel_user@student.42.fr
```

### 4. Configure the domain

```bash
sudo nano /etc/hosts
# Add this line:
127.0.0.1    dancel.42.fr
```

### 5. Create data directories

```bash
mkdir -p /home/dancel/data/db
mkdir -p /home/dancel/data/wordpress
```

These are created automatically by `make` but you can create them manually.

---

## Building and launching the project

```bash
# Build images and start all containers
make

# This runs:
# mkdir -p /home/dancel/data/db
# mkdir -p /home/dancel/data/wordpress
# docker compose -f srcs/docker-compose.yml up -d --build
```

Wait about 30 seconds for all services to initialize, especially WordPress
which waits for MariaDB to be ready before installing.

---

## Makefile targets

| Target | Description |
|---|---|
| `make` | Build images and start containers |
| `make down` | Stop containers (data preserved) |
| `make clean` | Stop containers and delete volumes and data |
| `make fclean` | Full clean including Docker images |
| `make re` | Full rebuild from scratch |

---

## Managing containers and volumes

### Container management

```bash
# See running containers
docker ps

# See all containers including stopped ones
docker ps -a

# Start a specific container
docker start mariadb

# Stop a specific container
docker stop mariadb

# Restart a specific container
docker restart mariadb

# See logs of a container
docker logs mariadb
docker logs wordpress
docker logs nginx

# Follow logs in real time
docker logs -f wordpress

# Enter a container shell
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

### Volume management

```bash
# See all volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_db_volume
docker volume inspect srcs_wp_volume
```

### Network management

```bash
# See all networks
docker network ls

# Inspect the project network
docker network inspect srcs_inception_network
```

---

## How each service works

### MariaDB

The `init.sh` script runs on container start:

    Check if database already exists (avoids re-initializing on restart)
    If not → start MariaDB temporarily without networking
    Create the database, the wpuser, set root password
    Shut down temporary MariaDB
    Start MariaDB in foreground on 0.0.0.0:3306


MariaDB listens on `0.0.0.0:3306` (configured in `conf/my.cnf`) so other
containers on the Docker network can reach it.

### WordPress

The `setup.sh` script runs on container start:

    Read secrets from /run/secrets/
    Wait for MariaDB to be ready (loop with mysqladmin ping)
    If wp-config.php does not exist → install WordPress with WP-CLI
    Create admin user and regular user
    Start php-fpm in foreground on 0.0.0.0:9000


### NGINX

The `setup.sh` script runs on container start:

    Generate a self-signed SSL certificate with openssl
    Start NGINX in foreground with daemon off


NGINX listens on port 443 (HTTPS only, TLSv1.2 and TLSv1.3).
It serves static files directly and forwards PHP requests to wordpress:9000.

---

## Where data is stored and how it persists

### On the host machine

/home/dancel/data/
├── db/         → MariaDB data files (/var/lib/mysql inside container)
└── wordpress/  → WordPress files (/var/www/wordpress inside container)


### How persistence works

Docker named volumes map these host directories to the containers:

Host                          Container
/home/dancel/data/db       →  mariadb:/var/lib/mysql
/home/dancel/data/wordpress →  wordpress:/var/www/wordpress
nginx:/var/www/wordpress (shared)


Data survives:
- Container restarts ✅
- `make down` + `make` ✅

Data is deleted by:
- `make clean` ❌
- `make fclean` ❌

---

## Debugging common issues

### WordPress stuck on "Waiting for MariaDB..."

```bash
# Check MariaDB is running
docker ps | grep mariadb

# Check MariaDB is reachable from WordPress
docker exec -it wordpress mysqladmin ping -h mariadb -u wpuser -pyourpassword

# Check MariaDB logs
docker logs mariadb
```

### 403 Forbidden on NGINX

```bash
# Check WordPress files exist
ls /home/dancel/data/wordpress

# Check NGINX logs
docker logs nginx

# Check file permissions inside wordpress container
docker exec -it wordpress ls -la /var/www/wordpress
```

### Certificate warning in browser

This is expected — the SSL certificate is self-signed.
Click "Advanced" → "Accept the risk and continue".

---

## Security notes

- Passwords are stored in `secrets/` and never written into Docker images
- `secrets/` and `srcs/.env` are in `.gitignore` — never commit them
- MariaDB is not exposed to the host machine (no ports in docker-compose)
- WordPress is not exposed to the host machine (no ports in docker-compose)
- Only NGINX is accessible from outside via port 443
- TLSv1.0 and TLSv1.1 are disabled — only TLSv1.2 and TLSv1.3 are allowed
