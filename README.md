# check-docker-frontend-backend

## Node.js

```sh
下記URLからバージョン確認
https://github.com/nodesource/distributions

DockerHubにそのバージョンがあるか確認
https://hub.docker.com/_/node

- HostMachine

ポート公開、ファイル等のバインドマウント
バインドマウントでホスト側の場合
ls -al $(pwd)/../..
等で参照できているか確認すること
(-itオプションなしだとすぐに落ちるので標準入力と端末をつけておく)

docker container run \
-it \
--name node \
--rm \
--detach \
--platform linux/amd64 \
--publish 3000:3000 \
--mount type=bind,src=$(pwd)/../..,dst=/home/app \
--mount type=bind,src=$(pwd)/.bashrc,dst=/root/.bashrc \
node:21.6.2


上記コマンドからDockerfile、docker-compose.ymlを作成


* create Next.js app

npx create-next-app


* boot

npm run dev

```

## PHP-FPM

```sh


- HostMachine

docker container run \
--name php \
--rm \
--detach \
--platform linux/amd64 \
php:8.3.9-fpm

コンテナから設定ファイルをダウンロード
docker cp php:/usr/local/etc/php/php.ini-development .
docker cp php:/usr/local/etc/php/php.ini-production .

オリジナル用のファイル名に変更しておく
mv php.ini-development 8.3.9-php.ini-development.org
mv php.ini-production 8.3.9-php.ini-production.org

コピー
cp -api 8.3.9-php.ini-development.org 8.3.9-php.ini-development
cp -api 8.3.9-php.ini-production.org 8.3.9-php.ini-production

.orgはorgディレクトリに移動させておく



```

## Nginx

```sh
- HostMachine

docker container run \
--name web \
--rm \
--detach \
--platform linux/amd64 \
nginx:1.23.2


- HostMachine

ポート公開オプションをつける
docker container run \
--name web \
--rm \
--detach \
--platform linux/amd64 \
--publish 80:80 \
nginx:1.23.2


- HostMachine

コンテナから設定ファイルをダウンロード
docker cp web:/etc/nginx/nginx.conf .
docker cp web:/etc/nginx/conf.d/default.conf .


- HostMachine

設定ファイルをバインドマウントする
docker container run \
--name web \
--rm \
--detach \
--platform linux/amd64 \
--publish 80:80 \
--mount type=bind,src=$(pwd)/nginx.conf,dst=/etc/nginx/nginx.conf \
--mount type=bind,src=$(pwd)/conf.d,dst=/etc/nginx/conf.d \
--mount type=bind,src=$(pwd)/../../../code,dst=/home/htdocs \
nginx:1.23.2


- HostMachine

ネットワークを作成する（既に作成済の場合は不要）
docker network create \
laravel-network

ログファイルマウント動作確認
docker container run \
--name ProjectName-nginx \
--rm \
--detach \
--platform linux/amd64 \
--publish 80:80 \
--mount type=bind,src=$(pwd)/nginx.conf,dst=/etc/nginx/nginx.conf \
--mount type=bind,src=$(pwd)/conf.d,dst=/etc/nginx/conf.d \
--mount type=bind,src=$(pwd)/logs,dst=/home/log/nginx \
--mount type=bind,src=$(pwd)/../../../code,dst=/home/htdocs \
--network laravel_default \
--network-alias nginx \
nginx:1.23.2

```

## MySQL

```sh
- HostMachine

docker container run \
--name db \
--rm \
--detach \
--platform linux/amd64 \
--env MYSQL_ROOT_PASSWORD=root \
mysql:9.0.0


- HostMachine

コンテナから設定ファイルをダウンロード
docker cp db:/etc/my.cnf .

ホスト側でmy.cnfを修正する
主に文字コード

- HostMachine

設定ファイルをバインドマウントする
docker container run \
--name db \
--rm \
--detach \
--platform linux/amd64 \
--env MYSQL_ROOT_PASSWORD=root \
--mount type=bind,src=$(pwd)/my.cnf,dst=/etc/my.cnf \
mysql:9.0.0


- Container

文字コードがutf8mb4になっているか確認

mysql -u root -p

mysql> show variables like "chara%";
+--------------------------+--------------------------------+
| Variable_name            | Value                          |
+--------------------------+--------------------------------+
| character_set_client     | utf8mb4                        |
| character_set_connection | utf8mb4                        |
| character_set_database   | utf8mb4                        |
| character_set_filesystem | binary                         |
| character_set_results    | utf8mb4                        |
| character_set_server     | utf8mb4                        |
| character_set_system     | utf8mb3                        |
| character_sets_dir       | /usr/share/mysql-9.0/charsets/ |
+--------------------------+--------------------------------+


- HostMachine

volumeを作成してデータの永続化
docker volume create \
--name db-store

マウントオプションをつける
docker container run \
--name db \
--rm \
--detach \
--platform linux/amd64 \
--env MYSQL_ROOT_PASSWORD=root \
--mount type=bind,src=$(pwd)/my.cnf,dst=/etc/my.cnf \
--mount type=volume,src=db-store,dst=/var/lib/mysql \
mysql:9.0.0


- HostMachine

ネットワークを作成する（既に作成済の場合は不要）
docker network create \
laravel-network

ネットワークオプションをつける
docker container run \
--name db \
--rm \
--detach \
--platform linux/amd64 \
--env MYSQL_ROOT_PASSWORD=root \
--mount type=bind,src=$(pwd)/my.cnf,dst=/etc/my.cnf \
--mount type=volume,src=db-store,dst=/var/lib/mysql \
--network laravel-network \
--network-alias db \
mysql:9.0.0


```

