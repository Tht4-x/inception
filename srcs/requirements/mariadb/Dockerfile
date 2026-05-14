FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY tools/init.sh /usr/local/bin/init.sh
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/99-custom.cnf
RUN chmod +x /usr/local/bin/init.sh

RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld

EXPOSE 3306

CMD ["bash", "-c", "/usr/local/bin/init.sh && mysqld_safe"]
