#!/bin/sh

echo "--------------------------------------------------------------------------------------------"
echo "[-] nginx init"
echo "--------------------------------------------------------------------------------------------"
echo 
[ ! -d "/etc/letsencrypt" ] && mkdir /etc/letsencrypt
for domain in $domains; do
    if [ ! -f "/etc/nginx/conf.d/$domain.conf" ]; then
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
            return 301 https://$host$request_uri;
        }
    }
    " > /etc/nginx/conf.d/$domain.conf
    fi
    echo "[-] $domain \(keysize: $keysize\)"
    echo
    
    [ -d "/etc/letsencrypt/staging/$domain" ] || mkdir -p /etc/letsencrypt/staging/$domain
    if [ ! -f "/etc/letsencrypt/staging/$domain/privkey.pem" ] || [ ! -f "/etc/letsencrypt/staging/$domain/fullchain.pem" ]; then
    sed -i 's/live/staging/g' /etc/nginx/conf.d/$domain.conf
    openssl req -x509 -nodes -newkey rsa:$keysize -days 1 -keyout "/etc/letsencrypt/staging/$domain/privkey.pem" -out "/etc/letsencrypt/staging/$domain/fullchain.pem" -subj "/CN=localhost"
    echo
    fi
    sleep 5s
done
if [ ! -f "/etc/letsencrypt/ssl-dhparams.pem" ]; then
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "/etc/letsencrypt/ssl-dhparams.pem"
    echo 
fi
if [ ! -f "/etc/nginx/options-ssl-nginx.conf" ]; then
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "/etc/nginx/options-ssl-nginx.conf"
    echo 
fi
echo "--------------------------------------------------------------------------------------------"
echo "[-] nginx-watch-reload init"
echo "--------------------------------------------------------------------------------------------"
while :
do
    for domain in $domains; do
    [ ! -f "/etc/letsencrypt/live/$domain/.certbot" ] && nginx -s reload
    done
    sleep 30s
done & nginx -g "daemon off;"
echo "--------------------------------------------------------------------------------------------"
echo