#!/bin/sh

# Load the environment variables from the .env file.
. ./.env

# Ensure the Nginx configuration directory exists.
if [ ! -d ./data/etc/nginx/conf.d/ ]; then
    mkdir -p ./data/etc/nginx/conf.d/
fi

# Loop over the domains.
for domain in $DOMAINS; do
# Generate the Nginx configuration for the current domain.
echo "
server {
    listen 80;
    server_name $domain;
    server_tokens off;
    http2 on;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$domain$request_uri;
    }
}

server { 
    listen 443 ssl;
    server_name $domain;
    server_tokens off;
    http2 on;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    include /etc/nginx/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass  http://api;
        # proxy_set_header    Host                $http_host;
        # proxy_set_header    X-Real-IP           $remote_addr;
        # proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
    }
}" > ./data/etc/nginx/conf.d/$domain.conf.template
done