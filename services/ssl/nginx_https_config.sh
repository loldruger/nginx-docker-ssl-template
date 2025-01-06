#!/bin/sh

domain="$1"
service="$2"

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

server { 
    listen 443 ssl;
    server_name ${domain};
    server_tokens off;
    http2 on;

    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;
    include /etc/nginx/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass  http://${service};
        proxy_set_header    Host                \$host;
        proxy_set_header    X-Real-IP           \$remote_addr;
        proxy_set_header    X-Forwarded-For     \$proxy_add_x_forwarded_for;
    }
}
EOF