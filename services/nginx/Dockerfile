FROM nginx:latest

COPY ./mime.types /mime.types
COPY ./nginx_init.sh /nginx_init.sh

# RUN apt-get update && apt-get install -y \
#     wget \
#     gettext \
#     && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq \
#     && chmod +x /usr/bin/yq \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*
