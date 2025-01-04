FROM alpine:latest

COPY ./main.sh /mount/main.sh
COPY ./http_config.sh /mount/http_config.sh
COPY ./https_config.sh /mount/https_config.sh

RUN chmod +x /mount/main.sh
RUN chmod +x /mount/http_config.sh
RUN chmod +x /mount/https_config.sh

RUN apk add --no-cache gettext yq

WORKDIR /mount
ENTRYPOINT ["/bin/sh"]
CMD ["/main.sh"]