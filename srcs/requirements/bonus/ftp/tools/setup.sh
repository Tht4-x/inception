#!/bin/bash
set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

if ! id -u ${FTP_USER} > /dev/null 2>&1; then
    useradd -m -d /var/www/wordpress ${FTP_USER}
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    chown -R ${FTP_USER}:${FTP_USER} /var/www/wordpress
    echo "FTP user created!"
fi

exec vsftpd /etc/vsftpd/vsftpd.conf
