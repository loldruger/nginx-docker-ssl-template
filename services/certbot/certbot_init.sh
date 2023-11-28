#!/bin/sh

echo "[-] sleep 30s"
sleep 30s
echo "--------------------------------------------------------------------------------------------"
echo "[-] certbot init"
echo "--------------------------------------------------------------------------------------------"
echo 

[ -f /etc/nginx/conf.d/$domain.conf ] || touch /etc/nginx/conf.d/$domain.conf

for domain in $domains; do
echo "[-] $domain \(keysize: $keysize\)"
echo
[ -d "/etc/letsencrypt/staging/$domain" ] || mkdir -p /etc/letsencrypt/staging
[ -d "/etc/letsencrypt/renewal/$domain" ] || mkdir -p /etc/letsencrypt/renewal
[ -d "/etc/letsencrypt/live/$domain" ] || mkdir -p /etc/letsencrypt/live

if [ "$staging" = "false" ] && [ ! -f "/etc/letsencrypt/live/$domain/.certbot" ]; then
    echo "[-] $domain staging false"
    certbot certonly -v --webroot -w /var/www/certbot -d $domain --email $email --rsa-key-size $keysize --agree-tos --force-renewal
    touch /etc/letsencrypt/live/$domain/.certbot
    sed -i 's/staging/live/g' /etc/nginx/conf.d/$domain.conf
    echo "[-] --- complete --- $domain"
    sleep 5s
fi
if [ "$staging" = "true" ] && [ ! -f "/etc/letsencrypt/live/$domain/.certbot" ]; then
    echo "[-] $domain staging true"
    certbot certonly -v --staging --webroot -w /var/www/certbot -d $domain --email $email --rsa-key-size $keysize --agree-tos --force-renewal
    touch /etc/letsencrypt/live/$domain/.certbot
    sed -i 's/staging/live/g' /etc/nginx/conf.d/$domain.conf
    echo "[-] --- complete --- $domain"
    sleep 5s
fi

if [ -f /etc/nginx/conf.d/$domain ]; then 
    rm /etc/nginx/conf.d/$domain
fi

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
    }" > /etc/nginx/conf.d/$domain.conf

done

echo "--------------------------------------------------------------------------------------------"
echo "[-] certbot init renew timer"
echo "--------------------------------------------------------------------------------------------"
echo 
trap exit TERM

while :
do
echo "[-] certbot renew"
[ -d "/etc/letsencrypt/renewal" ] && ls -l /etc/letsencrypt/renewal
certbot renew
[ -f "/etc/letsencrypt/live/$domain/.certbot" ] || touch /etc/letsencrypt/live/$domain/.certbot
echo "[-] sleep 12h"
sleep 12h
done