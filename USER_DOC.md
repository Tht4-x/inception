# User Documentation — Inception

## What is this project?

Inception is a web infrastructure running three services inside Docker containers:

- **NGINX** — the web server, handles secure HTTPS connections
- **WordPress** — the website and content management system
- **MariaDB** — the database storing all WordPress content

All services communicate through a private Docker network. The only way to
access the infrastructure from outside is through NGINX on port 443 (HTTPS).

Internet → NGINX (port 443) → WordPress → MariaDB


---

## Starting and stopping the project

### Start the project

```bash
cd ~/inception
make
```

This command builds the Docker images and starts all three containers.
Wait about 30 seconds for everything to initialize.

### Stop the project

```bash
make down
```

Stops all containers without deleting data. You can restart with `make` and
everything will still be there.

### Full clean (deletes all data)

```bash
make fclean
```

⚠️ Warning — this deletes all containers, images, and data including the
WordPress database and files. Only use this if you want to start from scratch.

---

## Accessing the website

### Website

Open a browser and go to:

https://dancel.42.fr


You will see a security warning because the SSL certificate is self-signed.
Click "Advanced" then "Accept the risk and continue" to proceed.

### WordPress administration panel

https://dancel.42.fr/wp-admin


---

## Credentials

### WordPress administrator

| Field | Value |
|---|---|
| Username | dancel_admin |
| Password | stored in `secrets/wp_admin_password.txt` |
| Email | dancel@student.42.fr |
| Role | Administrator |

### WordPress user

| Field | Value |
|---|---|
| Username | dancel |
| Password | stored in `secrets/wp_user_password.txt` |
| Email | dancel_user@student.42.fr |
| Role | Author |

### Database

| Field | Value |
|---|---|
| Database name | wordpress |
| User | wpuser |
| Password | stored in `secrets/db_password.txt` |
| Root password | stored in `secrets/db_root_password.txt` |

⚠️ Never share or commit the `secrets/` folder to Git.

---

## Checking that services are running

### See all running containers

```bash
docker ps
```

You should see three containers running:

NAMES       STATUS
nginx       Up X minutes
wordpress   Up X minutes
mariadb     Up X minutes


### Check a specific service

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Check WordPress users

```bash
docker exec -it wordpress wp user list --path=/var/www/wordpress --allow-root
```

### Test the website from the command line

```bash
curl -k https://dancel.42.fr
```

You should see HTML output from WordPress.

---

## What happens if a service crashes?

All containers are configured with `restart: unless-stopped`. This means if a
container crashes unexpectedly, Docker will automatically restart it.

You can verify this behavior:

```bash
# Simulate a crash
docker kill --signal=SIGSEGV mariadb

# Wait 5 seconds
sleep 5

# Check that it restarted automatically
docker ps
```

---

## Where is the data stored?

All persistent data is stored on the host machine at:

/home/dancel/data/
├── db/         → MariaDB database files
└── wordpress/  → WordPress website files


This means your data survives container restarts and rebuilds (unless you
run `make fclean`).
