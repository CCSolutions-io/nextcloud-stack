ARG NEXTCLOUD_VERSION=${NEXTCLOUD_VERSION}

FROM nextcloud:${NEXTCLOUD_VERSION}-fpm-alpine

MAINTAINER Antony Goetzschel <ago@ccsolutions.io>

RUN apk --no-cache add findutils && \
    rm -rf /var/cache/apk/*

COPY redis.config.php /usr/src/nextcloud/config/redis.config.php
COPY onlyoffice/ /usr/src/nextcloud/apps/onlyoffice

COPY *.sh /

USER www-dataT