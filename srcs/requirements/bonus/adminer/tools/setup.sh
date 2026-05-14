#!/bin/bash
set -e

php-fpm8.2

sleep 2

exec nginx -g "daemon off;"
