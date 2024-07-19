FROM php:8.0-fpm

# Composerのインストール
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# パッケージのインストール
COPY composer.json /var/www/html/
COPY composer.lock /var/www/html/
RUN composer install

# アプリケーションのコピー
COPY . /var/www/html
