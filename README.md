*This project has been created as part of the 42 curriculum by dancel.*

# Inception

## Description

Inception is a system administration project that uses Docker to set up a
small infrastructure composed of different services. The entire project runs
inside a virtual machine using Docker Compose.

### Services

- **NGINX** — the only entry point, handles HTTPS on port 443 with TLSv1.2/1.3
- **WordPress + php-fpm** — the CMS, runs PHP on port 9000
- **MariaDB** — the database, stores WordPress data on port 3306

### Design choices

#### Virtual Machines vs Docker

A Virtual Machine virtualizes an entire operating system including its kernel.
It is heavy, slow to start, and consumes a lot of resources.

Docker uses containers that share the host OS kernel. Each container runs only
what is strictly necessary for one service. Containers are lightweight, start
in seconds, and use far fewer resources than VMs.

| | Virtual Machine | Docker |
|---|---|---|
| Boot time | Minutes | Seconds |
| Size | GB | MB |
| Isolation | Full OS | Process |
| Resources | Heavy | Lightweight |

#### Secrets vs Environment Variables

Environment variables (`.env`) store non-sensitive configuration like database
names, usernames, or domain names. They are readable in plain text.

Docker secrets store sensitive data like passwords. They are mounted in
`/run/secrets/` inside the container and never written into the image. Even if
someone retrieves the Docker image, they cannot access the secrets.

| | Environment Variables | Docker Secrets |
|---|---|---|
| Use case | Configuration | Passwords, keys |
| Storage | Plain text | Encrypted |
| In image | Yes | No |
| In Git | Never (.gitignore) | Never (.gitignore) |

#### Docker Network vs Host Network

Host network shares the host machine's network directly with the container —
no isolation, the container can access everything on the host network.

Docker network (bridge) creates a private isolated network between containers.
Containers communicate by name, and are not directly accessible from outside
unless explicitly exposed via ports.

We use bridge network so containers are isolated and only NGINX is accessible
from outside via port 443.

#### Docker Volumes vs Bind Mounts

Bind mounts link a specific host directory to the container — tightly coupled
to the host filesystem structure.

Docker named volumes are managed by Docker and stored in a Docker-managed
location. They are more portable and recommended for persistent data.

The subject requires named volumes storing data in `/home/dancel/data/` on
the host machine.

## Instructions

### Prerequisites

- A Virtual Machine running Debian
- Docker and Docker Compose installed
- `make` installed

### Setup

```bash
# Clone the repository
git clone  inception
cd inception

# Create the secrets files
mkdir -p secrets
echo "your_db_password" > secrets/db_password.txt
echo "your_db_root_password" > secrets/db_root_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_password.txt
echo "your_wp_user_password" > secrets/wp_user_password.txt

# Configure your domain
echo "127.0.0.1 dancel.42.fr" | sudo tee -a /etc/hosts

# Build and start the project
make
```

### Usage

```bash
make        # Build and start all containers
make down   # Stop all containers
make clean  # Stop containers and remove volumes
make fclean # Full clean including images
make re     # Full rebuild
```

### Access

- Website: https://dancel.42.fr
- WordPress admin panel: https://dancel.42.fr/wp-admin

## Resources

### Documentation

- [Docker documentation](https://docs.docker.com)
- [Docker Compose documentation](https://docs.docker.com/compose)
- [NGINX documentation](https://nginx.org/en/docs)
- [WordPress CLI documentation](https://wp-cli.org)
- [MariaDB documentation](https://mariadb.com/kb/en)
- [php-fpm documentation](https://www.php.net/manual/en/install.fpm.php)
- [OpenSSL documentation](https://www.openssl.org/docs)
- [PID 1 and Docker best practices](https://cloud.google.com/architecture/best-practices-for-building-containers)

### AI Usage

Claude (Anthropic) was used during this project for the following tasks:

- Understanding Docker concepts (images, containers, volumes, networks)
- Understanding the role of each service (NGINX, php-fpm, MariaDB, WordPress)
- Explaining each line of configuration and scripts
- Debugging connection issues between containers

All AI-generated content was reviewed, understood, and validated before
being included in the project. Peer review was also performed to ensure
correctness.
