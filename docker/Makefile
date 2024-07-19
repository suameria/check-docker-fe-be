# ==============================
# Local Development Environment
# ==============================

.PHONY: help setup up down frontend-up frontend-down backend-up backend-down teardown ps logs

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

# 環境設定のセットアップ
setup: ## Set up the environment
	@echo "Setting up environment..."
	cp -n .env.example .env || echo ".env already exists"

# プロジェクトのセットアップと開始
up: setup frontend-up backend-up ## Set up and start the project
	@echo "Project setup and started."

# プロジェクトの停止
down: frontend-down backend-down ## Stop the project
	@echo "Project stopped."

# ティアダウン: コンテナ、ネットワーク、ボリュームのクリーンアップ（データボリュームを除く）
teardown: ## Tear down the project (containers, networks, volumes)
	@echo "Tearing down the project..."
	docker compose down
	@echo "Project torn down."

# フロントエンドのセットアップと開始
frontend-up: ## Set up and start the frontend
	@echo "Setting up and starting the frontend..."
	docker compose up -d frontend frontend-proxy
	if [ -f ../frontend/package.json ]; then \
	  cd ../frontend && npm run dev; \
	fi

# フロントエンドの停止
frontend-down: ## Stop and tear down the frontend
	@echo "Stopping and tearing down the frontend..."
	docker compose down frontend frontend-proxy

# バックエンドのセットアップと開始
backend-up: ## Set up and start the backend
	@echo "Setting up and starting the backend..."
	docker compose up -d backend backend-proxy

# バックエンドの停止
backend-down: ## Stop and tear down the backend
	@echo "Stopping and tearing down the backend..."
	docker compose down backend backend-proxy

# コンテナの状態を表示
ps: ## Display the status of all containers
	@echo "Displaying the status of all containers..."
	docker container ps

# ログを表示
logs: ## Display logs of all containers
	@echo "Displaying logs of all containers..."
	docker compose logs


# ============================
# Production Environment
# ============================

.PHONY: prod-setup prod-up prod-down

# 本番環境用のセットアップ
prod-setup: ## Set up the production environment
	@echo "Setting up production environment..."
	cp -n .env.production.example .env.production || echo ".env.production already exists"
	@echo "Installing frontend dependencies..."
	cd ../frontend && npm ci --production
	@echo "Installing backend dependencies..."
	cd ../backend && composer install --no-dev --optimize-autoloader

# 本番環境用のプロジェクトのセットアップと開始
prod-up: prod-setup ## Set up and start the production environment
	@echo "Setting up and starting the production environment..."
	docker compose -f docker-compose.prod.yml up -d
	@echo "Production environment setup and started."

# 本番環境用のプロジェクトの停止
prod-down: ## Stop the production environment
	@echo "Stopping the production environment..."
	docker compose -f docker-compose.prod.yml down
	@echo "Production environment stopped."
