ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

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

COPY ./.bashrc /root/.bashrc

ARG PHP_VERSION
COPY ./config/${PHP_VERSION}-php.ini-development /usr/local/etc/php/php.ini

# Composer インストール
COPY --from=composer /usr/bin/composer /usr/bin/composer

ARG WORKDIR
WORKDIR ${WORKDIR}

CMD ["php-fpm"]
