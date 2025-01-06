#!/bin/sh

domains="$1"
service="$2"

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