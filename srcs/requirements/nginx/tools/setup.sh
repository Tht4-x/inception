#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/private.key \
    -out /etc/nginx/ssl/certificate.crt \
    -subj "/C=FR/ST=BFC/L=Belfort/O=42/CN=dancel.42.fr"

exec nginx -g "daemon off;"
