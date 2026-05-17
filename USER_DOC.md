# User Documentation — Inception

## What is this project?

Inception is a project that uses Docker to set up a small infrastructure composed of different services. The entire project runs inside a virtual machine using Docker Compose.

It runs three services inside Docker containers:

- NGINX — handles HTTPS on port 443 with TLSv1.2/1.3
- WordPress + php-fpm — the Content Management System, runs PHP on port 9000
- MariaDB — the database, stores WordPress data on port 3306
- Redis — object cache for WordPress, improves performance
- FTP — file transfer server pointing to the WordPress volume
- Static website — presentation site (HTML/CSS) on port 80
- Adminer — web interface to manage MariaDB on port 8080
- Netdata — real-time monitoring dashboard for all containers on port 19999

All services communicate through a private Docker network. The only way to
access the infrastructure from outside is through NGINX on port 443 (HTTPS).

Internet → NGINX (port 443) → WordPress → MariaDB


## Starting and stopping the project

### Start the project

cd ~/inception
make

This command builds the Docker images and starts all three containers.

### Stop the project

make down

Stops all containers without deleting data.


## Accessing the website

### Website

Open a browser and go to:

https://dancel.42.fr


You will see a security warning because the SSL certificate is self-signed.
Click "Advanced" then "Accept the risk and continue" to proceed.

### WordPress administration panel

https://dancel.42.fr/wp-admin

### Bonus WebSite

http://dancel.42.fr


## Credentials

Locate in inception/secrets


## Checking that services are running

### See all running containers

docker ps

You should see three containers running:

NAMES       STATUS
nginx       Up X minutes
wordpress   Up X minutes
mariadb     Up X minutes


### Check a specific service

docker logs nginx
docker logs wordpress
docker logs mariadb

### Check WordPress users

docker exec -it wordpress wp user list --path=/var/www/wordpress --allow-root

### Test the website from the command line

curl -k https://dancel.42.fr

You should see HTML output from WordPress.


## Where is the data stored?

All persistent data is stored on the host machine at /home/dancel/data/

This means your data survives container restarts and rebuilds
