FROM php:8.3-fpm

RUN apt update

RUN apt install -y git zip unzip

# PHPの標準の拡張モジュールのインストール(有効化も含む)
RUN docker-php-ext-install \
  bcmath \
  opcache \
  pdo_mysql

# PHP Extension Community Library インストールし有効化
RUN pecl install apcu && \
  docker-php-ext-enable apcu

# Composer インストール
COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
