# An Easy-Deployable Web Backend Server Infrastructure Kit
## Introduction

This template provides a ready-to-use foundation for your web backend, featuring `Nginx`, `PostgreSQL`, and `PGAdmin`, all secured with `Let's Encrypt SSL`. It simplifies the deployment process and allows you to focus on building your application.

# Getting Started

## Prerequisite:
 1. You need to setup DNS config
 2. Set .env file to yours

.env:
```bash
#services
SERVICES="
    api: api.example.org:8080,
    web: example.org:8081,
    pga: pga.example.org:9090
"

#certbot
STAGING="true" #Set it to "true" for testing
EMAIL="example@example.org"
DOMAINS="" #automatically filled out when executing ./deploy.sh

#postgres && pg-admin
POSTGRES_DATABASE="example_db"
POSTGRES_PASSWORD="example_password"

PGADMIN_DEFAULT_EMAIL="example@example.org"
PGADMIN_DEFAULT_PASSWORD="example_password"
```

```sh
curl -sSL https://install.python-poetry.org | python3 -
export PATH="/root/.local/bin:$PATH"

poetry run python x.py
```

 3. **Deploy your services:**
 ```
 $ sh deploy.sh
 ```

on your terminal. it will automatically set up everything.

if you get successful result but cannot access through your domain, `$ docker compose restart nginx` to reload `nginx service`

# Troubleshooting
 1. If you encounter an error during the certbot phase, such as `Certbot failed to authenticate some domains... Fetching <url> Connection refused`, Verify that the file `/data/etc/letsencrypt/ssl-dhparams.pem` is not empty.
if it is, clean up your docker network and data files, then proceed with the second step below.

 2. If you get troubles on internet connection in container, uncomment the network configurations at the end of the `docker-compose.yaml` file, which set the MTU length to 1450 or another value. 

# Roadmap
 1. Support multi-repo configuration.
 2. Adopt `Ansible` to configure multiple host servers.
 3. Adopt `Jenkins` to build CI/CD pipeline
 4. Improve error handling and logging.
 