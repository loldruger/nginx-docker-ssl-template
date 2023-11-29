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