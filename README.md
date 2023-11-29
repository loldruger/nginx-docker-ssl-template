# Introduction

this template runs on `tokio`, `sqlx`, `axum` in `Rust programming language` with `nginx`, `postgres` and `redis`, over `Let's Encrypt SSL`

you can easily replace backend system, currently running on Rust axum, with whatever you want!

# Getting started

## Prerequisite
 1. You need to have DNS setup
 2. Set .env file to yours

.env:
```python
#certbot
STAGING="true" #if you are on testing, keep it true
EMAIL="example@example.org"
DOMAINS="project-1.com" #project-1.com project-2.com...

#postgres && pg-admin
POSTGRES_DATABASE="example_db"
POSTGRES_PASSWORD="example_password"

PGADMIN_DEFAULT_EMAIL="example@example.org"
PGADMIN_DEFAULT_PASSWORD="example_password"
```

 3. Generate nginx configuration template files for each `DOMAINS` by executing
 ```
 $ sh init.sh
 ```
Which yields `domain.conf.template` files into `/data/etc/nginx/conf.d`

 4. Modify the nginx configuration template files to what you need. And rename them without the `.template` extension.

and finally, Enter this command:
```
$ sh deploy.sh
```
on your terminal. it will be all automatically set up. And it now supports multiple domains certification!

if you get successful result but cannot access through your domain,  `$ docker compose restart` to reload `nginx service`

# TroubleShooting
 1. If you get an error at certbot phase, like `Certbot failed to authenticate some domains... Fetching <url> Connection refused`, Check if the file `/data/etc/letsencrypt/ssl-dhparams.pem` is 0 Bytes.
if so, clean up your docker network and data files, then follow the second step of fitting MTU length.

 2. If you get troubles on internet connection in container, uncomment network set up bottom of the `docker-compose.yaml` file to fit the MTU length 1450 or else. 
