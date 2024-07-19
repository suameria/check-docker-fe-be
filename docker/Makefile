help: ## コマンドヘルプの表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

# ==============================
# Common
# ==============================

ps: ## コンテナの状態を表示
	@docker container ps

logs: ## ログを表示
	@docker compose logs

front: ## フロントエンドコンテナに入る
	@docker compose exec frontend /bin/sh

back: ## バックエンドコンテナに入る
	@docker compose exec backend /bin/bash

# ==============================
# Local Development Environment
# ==============================

setup: ## 環境設定のセットアップ
	@cp -n .env.example .env || echo ".env already exists"

up: setup frontend-up backend-up ## プロジェクトのセットアップと開始

down: ## プロジェクトの停止
	@docker compose down

frontend-up: ## フロントエンドのセットアップと開始
	@docker compose up -d frontend frontend-proxy

backend-up: ## バックエンドのセットアップと開始
	@docker compose up -d backend backend-proxy

# ============================
# Production Environment
# ============================

prod-setup: ## 本番環境用のセットアップ
	@cp -n .env.production.example .env.production || echo ".env.production already exists"
	@cd ../frontend && npm ci --production
	@cd ../backend && composer install --no-dev --optimize-autoloader

prod-up: prod-setup ## 本番環境用のプロジェクトのセットアップと開始
	@docker compose -f docker-compose.prod.yml up -d

prod-down: ## 本番環境用のプロジェクトの停止
	@docker compose -f docker-compose.prod.yml down
