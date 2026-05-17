# Developer Documentation — Inception

## Prerequisites

- A Virtual Machine running Debian Bookworm
- Docker installed
- Docker Compose installed
- make installed
- Git installed

### Install prerequisites on Debian
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 make git

## Environment setup from scratch

### 1. Clone the repository

git clone <your_repo> inception
cd inception

### 2. Create the secrets files

These files are not in the repository for security reasons.
You must copy/past the secrets repertory from inception into the root of your repo

### 3. Configure the domain

sudo nano /etc/hosts
Add this line:
127.0.0.1    dancel.42.fr

## Building and launching the project

make         Build images and start containers 
make down    Stop containers (data preserved) 
make clean   Stop containers and delete volumes and data 
make fclean  Full clean including Docker images 
make re Full rebuild from scratch 


## Managing containers and volumes

### Container management

#### See running containers
docker ps

#### See all containers including stopped ones
docker ps -a

#### Start a specific container
docker start mariadb

#### Stop a specific container
docker stop mariadb

#### Restart a specific container
docker restart mariadb

#### See logs of a container
docker logs mariadb
docker logs wordpress
docker logs nginx

#### Follow logs in real time
docker logs -f wordpress

#### Enter a container shell
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

### Volume management

#### See all volumes
docker volume ls

#### Inspect a volume
docker volume inspect srcs_db_volume
docker volume inspect srcs_wp_volume

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

### Redis

Runs as a standalone cache server on port 6379. WordPress connects to it
via the redis-cache plugin. Stores page cache in RAM for faster response times.
Protected mode is disabled to allow connections from other containers.

### FTP

Runs vsftpd on port 21 with passive mode on ports 21100-21110.
Creates a dedicated FTP user pointing to the WordPress volume at
`/var/www/wordpress`. Allows direct file management of WordPress files.

### Static website

Serves a static HTML/CSS page via NGINX on port 80. No PHP, no database.
Presents Dancel Flour Co., a fictional wheat flour company based in Mulhouse.

### Adminer

Runs NGINX + php-fpm in the same container on port 8080. Downloads Adminer
(a single PHP file) and serves it to provide a visual interface for managing
the MariaDB database.

### Netdata

Monitors all containers and the host system in real time on port 19999.
Mounts `/proc`, `/sys` and the Docker socket in read-only mode to collect
metrics about CPU, RAM, network, disk and container performance.


## Where data is stored and how it persists

All persistent data is stored on the host machine at /home/dancel/data/

This means your data survives when container restarts and rebuilds (exept for make fclean)