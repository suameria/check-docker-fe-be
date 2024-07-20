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
