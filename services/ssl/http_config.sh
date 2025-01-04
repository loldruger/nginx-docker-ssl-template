#!/bin/sh

domain="$1"

cat << EOF > "./etc/nginx/conf.d/${domain}.conf"
server {
    listen 80;
    server_name ${domain};
    server_tokens off;
    http2 on;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}
EOF