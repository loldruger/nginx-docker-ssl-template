# Introduction

These shell scripts in docker-compose.yaml are from https://gist.github.com/hp8wvvvgnj6asjm7/f13551ec0adfbda7bc5c3a3f9fa3a3a9

this template runs on `tokio`, `sqlx`, `axum` in `Rust programming language` with `nginx`, `postgres` and `redis`.

you can easily replace backend system, currently running on Rust axum, with whatever you want!

# Getting started

## Prerequisite
 1. You need to have a domain that is DNS setup
 2. Set .env file to yours
 3. Change server_name `example.org` in `/data/etc/nginx/conf.d/app.conf` to your own domain
 4. 
and you just enter `$ docker compose up` on your terminal. ~~it's all automatically set up~~

you should `docker compose restart` to reload `nginx service`..

# TroubleShooting

if you get troubles on internet connection in container, uncomment network set up bottom of the `docker-compose.yaml` file to fit the MTU length 1450 or else. 
