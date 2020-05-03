ARG NGINX_VERSION=${NGINX_VERSION}

FROM nginx:${NGINX_VERSION}-alpine

MAINTAINER Antony Goetzschel <ago@ccsolutions.io>

RUN adduser -u 1000 -D -S -G www-data www-data

COPY nginx.conf /etc/nginx/nginx.conf

USER www-data