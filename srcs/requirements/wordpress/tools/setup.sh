#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
WP_PATH="/var/www/wordpress"

echo "Waiting for MariaDB..."
while ! mysqladmin ping -h mariadb -u ${MYSQL_USER} -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    sleep 1
done
echo "MariaDB is ready!"

if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    wp core download --path=${WP_PATH} --allow-root
    wp config create \
        --path=${WP_PATH} \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --allow-root
    wp core install \
        --path=${WP_PATH} \
        --url=https://${DOMAIN_NAME} \
        --title="${WP_TITLE}" \
        --admin_user=${WP_ADMIN_LOGIN} \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root
    wp user create \
        --path=${WP_PATH} \
        ${WP_USER_LOGIN} ${WP_USER_EMAIL} \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    echo "WordPress installed successfully!"
else
    echo "WordPress already installed, skipping..."
fi

exec php-fpm8.2 -F
