*This project has been created as part of the 42 curriculum by dancel.*

# Inception

## Description

Inception is a project that uses Docker to set up a small infrastructure composed of different services. The entire project runs inside a virtual machine using Docker Compose.

### Services

- NGINX — handles HTTPS on port 443 with TLSv1.2/1.3
- WordPress + php-fpm — the Content Management System, runs PHP on port 9000
- MariaDB — the database, stores WordPress data on port 3306
- Redis — object cache for WordPress, improves performance
- FTP — file transfer server pointing to the WordPress volume
- Static website — presentation site (HTML/CSS) on port 80
- Adminer — web interface to manage MariaDB on port 8080
- Netdata — real-time monitoring dashboard for all containers on port 19999

### Virtual Machines vs Docker

A Virtual Machine virtualizes an entire operating system including its kernel. It is heavy, slow to start, and consumes a lot of resources. Docker uses containers that share the host OS kernel. Each container runs only what is strictly necessary for one service. Containers are lightweight, start in seconds, and use far fewer resources than VMs.

### Secrets vs Environment Variables

Environment variables store non-sensitive configuration like database
names, usernames, or domain names. They are readable in plain text.

Docker secrets store sensitive data like passwords. They are mounted inside the container and never written into the image. Even if
someone retrieves the Docker image, they cannot access the secrets.

### Docker Network vs Host Network

Host network shares the host machine's network directly with the container —
no isolation, the container can access everything on the host network. Docker network (bridge) creates a private isolated network between containers. Containers communicate by name, and are not directly accessible from outside unless explicitly exposed via ports. We use bridge network so containers are isolated and only NGINX is accessible from outside via port 443.

### Docker Volumes vs Bind Mounts

Bind mounts link a specific host directory to the container — tightly coupled to the host filesystem structure.
Docker named volumes are managed by Docker and stored in a Docker-managed
location. They are more portable and recommended for persistent data.

The subject requires named volumes storing data in `/home/dancel/data/` on
the host machine.

## Instructions

### Prerequisites

- A Virtual Machine running Debian
- Docker and Docker Compose installed
- make installed
- git installed
- sudo installed 


### Setup

git clone  inception
cd inception
copy/past the secrets files
make
```
 Usage
make        # Build and start all containers
make down   # Stop all containers
make clean  # Stop containers and remove volumes
make fclean # Full clean including images
make re     # Full rebuild
```

### Access

- Website: https://dancel.42.fr
- WordPress admin panel: https://dancel.42.fr/wp-admin
- Bonus website: http://dancel.42.fr

## Resources

### Documentation
- https://www.redhat.com/fr/topics/containers/what-is-docker
- https://docs.docker.com/compose/
- https://learn.microsoft.com/en-us/visualstudio/docker/tutorials/docker-tutorial?WT.mc_id=vscode_docker_aka_getstartedwithdocker
- https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671
- https://tuto.grademe.fr/inception/
- https://docs.docker.com
- https://docs.docker.com/compose
- https://nginx.org/en/docs
- https://wp-cli.org
- https://mariadb.com/kb/en
- https://www.php.net/manual/en/install.fpm.php
- https://www.openssl.org/docs
- https://cloud.google.com/architecture/best-practices-for-building-containers

### AI Usage

ChatGPT was used during this project for understanding Docker concepts (images, containers, volumes, networks), understanding the role of each service (NGINX, php-fpm, MariaDB, WordPress) and for generating the html code for the static bonus website
