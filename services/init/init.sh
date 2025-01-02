#!/bin/sh

# Ensure the Nginx configuration directory exists.
if [ ! -d ./data/etc/nginx/conf.d/ ]; then
    mkdir -p ./data/etc/nginx/conf.d/
fi

envsubst < docker-compose.yaml > docker-compose.expanded.yaml

# Extract service:domain:port mappings
service_mappings=$(yq e '.services | to_entries[] | select(.value.environment.VIRTUAL_HOST != null) | 
  .key + ":" + .value.environment.VIRTUAL_HOST + ":" + (.value.ports[0] | split(":")[1])' docker-compose.expanded.yaml)

domains=$(grep -A 10 "^#domains" .env | grep "_DOMAIN.*=" | sed 's/^.*= *"\(.*\)"$/\1/')

echo "Service mappings: $service_mappings"
echo "Domains: $domains"

for domain in $domains; do
  # Extract service and port using domain as key
  mapping=$(echo "$service_mappings" | grep -F ":$domain:" || true)
  service=$(echo "$mapping" | cut -d':' -f1)
  port=$(echo "$mapping" | cut -d':' -f3)

  config_content=$(cat << EOF
server {
    listen 80;
    server_name $domain;
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
    server_name $domain;
    server_tokens off;
    http2 on;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    include /etc/nginx/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass  http://$service:$port;
        proxy_set_header    Host                \$http_host;
        proxy_set_header    X-Real-IP           \$remote_addr;
        proxy_set_header    X-Forwarded-For     \$proxy_add_x_forwarded_for;
    }
}
EOF
)
  eval "echo \"$config_content\"" > "./data/etc/nginx/conf.d/${domain}.conf.template"
  eval "echo \"$config_content\"" > "./data/etc/nginx/conf.d/${domain}.conf"
done