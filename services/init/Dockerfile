FROM alpine:latest

COPY ./init.sh /init.sh
RUN chmod +x /init.sh
RUN apk add --no-cache gettext yq

ENTRYPOINT ["/bin/sh"]
CMD ["/init.sh"]