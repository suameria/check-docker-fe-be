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


```sh

## PHP-FPM

- HostMachine

docker container run \
--name php \
--rm \
--detach \
--platform linux/amd64 \
php:8.2.0-fpm


## Nginx

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


## MySQL

- HostMachine

docker container run \
--name db \
--rm \
--detach \
--platform linux/amd64 \
--env MYSQL_ROOT_PASSWORD=root \
mysql:5.7.40


- HostMachine

コンテナから設定ファイルをダウンロード
docker cp db:/etc/my.cnf .


- HostMachine

設定ファイルをバインドマウントする
docker container run \
--name db \
--rm \
--detach \
--platform linux/amd64 \
--env MYSQL_ROOT_PASSWORD=root \
--mount type=bind,src=$(pwd)/my.cnf,dst=/etc/my.cnf \
mysql:5.7.40


- Container

文字コードがutf8mb4になっているか確認
* character_set_systemはmysql側で常にutf8らしい

mysql -u root -p

mysql> show variables like "chara%";
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8mb4                    |
| character_set_connection | utf8mb4                    |
| character_set_database   | utf8mb4                    |
| character_set_filesystem | binary                     |
| character_set_results    | utf8mb4                    |
| character_set_server     | utf8mb4                    |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+


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
mysql:5.7.40


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
mysql:5.7.40


## MailHog


- HostMachine

docker container run \
--name mail \
--rm \
--detach \
--platform linux/amd64 \
--publish 8025:8025 \
mailhog/mailhog:v1.0.1

*
2022/12/10 08:26:46 [SMTP] Binding to address: 0.0.0.0:1025
[HTTP] Binding to address: 0.0.0.0:8025
2022/12/10 08:26:46 Serving under http://0.0.0.0:8025/


- HostMachine

ネットワークを作成する（既に作成済の場合は不要）
docker network create \
laravel-network

ネットワークオプションをつける
docker container run \
--name mail \
--rm \
--detach \
--platform linux/amd64 \
--publish 8025:8025 \
--network laravel-network \
--network-alias mail \
mailhog/mailhog:v1.0.1


```

