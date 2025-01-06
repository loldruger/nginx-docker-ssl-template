# Introduction

this template runs on `tokio`, `sqlx`, `axum` in `Rust programming language` with `nginx`, `postgres` and `redis`, over `Let's Encrypt SSL`

you can easily replace backend system, currently running on Rust axum, with whatever you want!

# Getting Started

## Prerequisite
 1. You need to setup DNS config
 2. Set .env file to yours

.env:
```python
#services
SERVICES="
    api: api.example.com:8080,
    web: example.com:8081,
    pga: pga.example.com:9090
"

#certbot
STAGING="true" #if you are testing, keep it true
EMAIL="example@example.org"
DOMAINS="" #filled out when executing ./deploy.sh

#postgres && pg-admin
POSTGRES_DATABASE="example_db"
POSTGRES_PASSWORD="example_password"

PGADMIN_DEFAULT_EMAIL="example@example.org"
PGADMIN_DEFAULT_PASSWORD="example_password"
```

 3. Deploy your services with this one command input
 ```
 $ sh deploy.sh
 ```

on your terminal. it will automatically set all the things up.

if you get successful result but cannot access through your domain,  `$ docker compose restart nginx` to reload `nginx service`

# TroubleShooting
 1. If you get an error at certbot phase, like `Certbot failed to authenticate some domains... Fetching <url> Connection refused`, Check if the file `/data/etc/letsencrypt/ssl-dhparams.pem` is 0 Bytes.
if so, clean up your docker network and data files, then follow the second step of fitting MTU length.

 2. If you get troubles on internet connection in container, uncomment network set up bottom of the `docker-compose.yaml` file to fit the MTU length 1450 or else. 
