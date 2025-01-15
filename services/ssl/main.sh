#!/bin/sh

set -a
[ -f .env ] && source .env
set +a

# Ensure the Nginx configuration directory exists.
if [ ! -d "./mount/etc/nginx/conf.d" ]; then
  mkdir -p "./mount/etc/nginx/conf.d"
fi

if [ -f "docker-compose.yaml" ]; then
  envsubst < docker-compose.yaml > docker-compose.expanded.yaml
fi

service_mappings=""
if [ -f docker-compose.expanded.yaml ]; then
  service_mappings=$(yq e '
    .services 
    | to_entries[] 
    | select(.value.environment.VIRTUAL_HOST != null)
    | .key + ":" 
      + .value.environment.VIRTUAL_HOST + ":" 
      + (.value.ports[0] | split(":")[1])
  ' docker-compose.expanded.yaml)
fi

domains=$(sed -n '/#domains/,/#domains_end/p' .env | sed 's/^.*= *"\(.*\)"$/\1/')

MAX_ATTEMPTS=60
               
for domain in $domains; do
  ./nginx_http_config.sh "$domain"

  domain_var=$(echo "$domain" | tr '[:lower:].' '[:upper:]_')
  attempts=1

  while [ ! -f "./mount/etc/letsencrypt/live/$domain/fullchain.pem" ]; do
    if [ $attempts -gt $MAX_ATTEMPTS ]; then
      echo "Failed to obtain certificate for $domain"
      exit 1
    fi
    sleep 5
    attempts=$((attempts+1))
  done

  mapping=$(echo "$service_mappings" | grep -F ":$domain:" || true)
  service=$(echo "$mapping" | cut -d':' -f1)

  ./nginx_https_config.sh "$domain" "$service"
done

if [ ! -f "./mount/etc/letsencrypt/ssl-dhparams.pem" ]; then
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "./mount/etc/letsencrypt/ssl-dhparams.pem"
fi
if [ ! -f "./mount/etc/nginx/options-ssl-nginx.conf" ]; then
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "./mount/etc/nginx/options-ssl-nginx.conf"
fi

