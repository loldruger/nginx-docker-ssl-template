#!/bin/sh

ENV_FILE=".env"
DOMAINS=""

services=$(grep '^SERVICES=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '"')
ifs=',' read -ra service_list <<< "$services"

for service in "${service_list[@]}"; do
    service_info=$(echo "$service" | xargs)
    ifs=':' read -r service domain port <<< "$service"
    domain=$(echo "$domain" | xargs)

    if [ -n "$domain" ]; then
        if [ -z "$DOMAINS" ]; then
            DOMAINS="$domain"
        else
            DOMAINS="$DOMAINS,$domain"
        fi
    fi
done

DOMAINS=$(echo "$DOMAINS" | tr ',' '\n' | sort | uniq | paste -sd "," -)

if grep -q '^DOMAINS=' "$ENV_FILE"; then
    sed -i "s/^DOMAINS=.*/DOMAINS=\"$DOMAINS\"/" "$ENV_FILE"
else
    echo "DOMAINS=\"$DOMAINS\"" >> "$ENV_FILE"
fi

docker compose up 