# 定数の宣言
## Directory
DIR_DOCKER=docker
DIR_FRONTEND=frontend
DIR_BACKEND=backend
## docker service name
SERVICE_FRONTEND=frontend
SERVICE_BACKEND=backend
SERVICE_FRONTEND_PROXY=frontend-proxy
SERVICE_BACKEND_PROXY=backend-proxy
## docker command
DOCKER_COMPOSE=docker compose
DOCKER_COMPOSE_UP_D=$(DOCKER_COMPOSE) up -d
DOCKER_COMPOSE_EXEC=$(DOCKER_COMPOSE) exec

# ==============================
# Common
# ==============================

.PHONY: help
help: ## コマンドヘルプ表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

.PHONY: build
build: ## ビルド
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) build
# @cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) build --no-cache --force-rm

.PHONY: up-build
up-build: ## ビルドとアップ
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE_UP_D) --build

.PHONY: ps
ps: ## コンテナの状態を表示
	@cd $(DIR_DOCKER) && docker container ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

.PHONY: psa
psa: ## コンテナの状態を全表示
	@cd $(DIR_DOCKER) && docker container ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

.PHONY: logs
logs: ## ログを表示
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) logs

.PHONY: system-prune-all
system-prune-all: ## Dockerシステム全体の不要なリソースを削除
	@docker system prune -a --volumes


# ==============================
# Local Development Environment
# ==============================

# ---------- Prepare ----------

.PHONY: setup
setup: ## 環境のセットアップ
	@mkdir -p $(DIR_BACKEND)
	@mkdir -p $(DIR_FRONTEND)
	@cd $(DIR_DOCKER) && cp -n .env.example .env || true
	@make build
	@make up
	@if [ -f $(DIR_BACKEND)/composer.json ]; then \
		make composer-install; \
	fi
	@if [ -f $(DIR_FRONTEND)/package.json ]; then \
		make npm-install; \
	fi

# ---------- Install ----------

.PHONY: install-laravel
install-laravel: ## backend コンテナで最新の Laravel をインストール
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_BACKEND) \
	composer create-project --prefer-dist laravel/laravel .

.PHONY: composer-laravel
composer-install: ## backend コンテナで composer install 実行
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_BACKEND) \
	composer install

.PHONY: install-next
install-next: ## frontend コンテナで最新の Next.js をインストール
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_FRONTEND) npx create-next-app@latest .

.PHONY: npm-install
npm-install: ## frontend コンテナで npm ci 実行
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_FRONTEND) npm ci

# ---------- Container ----------

.PHONY: up
up: ## サービス起動
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE_UP_D)

.PHONY: down
down: ## サービス停止
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) down

.PHONY: frontend-up
frontend-up: ## frontend, frontend-proxy サービス起動
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_UP_D) $(SERVICE_FRONTEND) $(SERVICE_FRONTEND_PROXY)

.PHONY: frontend-npm-run-dev
frontend-npm-run-dev: ## frontend コンテナで npm run dev 実行
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_FRONTEND) npm run dev

.PHONY: backend-up
backend-up: ## backend, backend-proxy サービス起動
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_UP_D) $(SERVICE_BACKEND) $(SERVICE_BACKEND_PROXY)

# ---------- Enter the container ----------

.PHONY: frontend
frontend: ## frontend コンテナに入る
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_FRONTEND) /bin/sh

.PHONY: backend
backend: ## backend コンテナに入る
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_BACKEND) /bin/bash


# ============================
# Production Environment
# ============================

# .PHONY: prod-setup
# prod-setup: ## 本番環境用のセットアップ
# 	@cd $(DIR_DOCKER) && cp -n .env.production.example .env || true
# 	@cd ../$(DIR_FRONTEND) && npm ci --production
# 	@cd ../$(DIR_BACKEND) && composer install --no-dev --optimize-autoloader

# .PHONY: prod-up
# prod-up: ## 本番環境用のプロジェクトのセットアップと開始
# 	@make prod-setup
# 	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) -f docker-compose.prod.yml up -d

# .PHONY: prod-down
# prod-down: ## 本番環境用のプロジェクトの停止
# 	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) -f docker-compose.prod.yml down
