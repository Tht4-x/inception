FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    nginx \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget -q "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" \
    -O /var/www/html/index.php && \
    chmod 644 /var/www/html/index.php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY conf/nginx.conf /etc/nginx/sites-available/default
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 8080

CMD ["setup.sh"]