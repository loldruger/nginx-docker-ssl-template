#!/bin/sh

set -a
source .env
set +a

mkdir -p /etc/nginx;
cp /mime.types /etc/nginx/mime.types

envsubst < docker-compose.yaml > docker-compose.expanded.yaml

service_mappings=$(yq e '.services | to_entries[] | select(.value.environment.VIRTUAL_HOST != null) | 
  .key + ":" + .value.environment.VIRTUAL_HOST + ":" + (.value.ports[0] | split(":")[1])' docker-compose.expanded.yaml)

# First generate upstream configs
upstream_config=""
for mapping in ${service_mappings}; do
    service="$(echo "${mapping}" | cut -d':' -f1)"
    port="$(echo "${mapping}" | cut -d':' -f3)"
    upstream_config="${upstream_config}    upstream ${service} {
        server ${service}:${port};
        keepalive 1024;
    }
"
done

# Then create full nginx config
cat << EOF > /etc/nginx/nginx.conf
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

${upstream_config}
    server {
        server_name _;
        listen 80 default_server;
        listen [::]:80 default_server;
        listen 443 default_server;
        listen [::]:443 default_server;
        ssl_reject_handshake on;
        ssl_session_tickets off;
        return 444;
    }

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;
    include /etc/nginx/conf.d/*.conf;
}
EOF

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