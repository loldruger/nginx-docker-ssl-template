#!/bin/sh

ENV_FILE=".env"
DOMAINS=""

services=$(grep '^SERVICES=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '"')

echo "$services" | tr ',' '\n' | while read service; do
    service_info=$(echo "$service" | xargs)
    domain=$(echo "$service_info" | cut -d':' -f2 | xargs)

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