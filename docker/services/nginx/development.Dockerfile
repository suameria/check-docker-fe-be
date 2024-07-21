ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

ARG NGINX_VERSION
COPY ./config/development-${NGINX_VERSION}-nginx.conf /etc/nginx/nginx.conf
