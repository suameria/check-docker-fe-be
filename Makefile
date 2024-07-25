# Declaration of constants
## Directory
DIR_DOCKER=docker
DIR_FRONTEND=frontend
DIR_BACKEND=backend
## docker service name
SERVICE_FRONTEND=frontend
SERVICE_BACKEND=backend
SERVICE_FRONTEND_PROXY=frontend-proxy
SERVICE_BACKEND_PROXY=backend-proxy
SERVICE_MYSQL=mysql
## docker command
DOCKER_COMPOSE=docker compose
DOCKER_COMPOSE_UP_D=$(DOCKER_COMPOSE) up -d
DOCKER_COMPOSE_EXEC=$(DOCKER_COMPOSE) exec

# ==============================
# Common
# ==============================

.PHONY: help
help: ## Display command help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

.PHONY: build
build: ## Build
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) build
# @cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) build --no-cache --force-rm

.PHONY: up
up: ## Start services
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE_UP_D)

.PHONY: upb
upb: ## Build and start
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE_UP_D) --build

.PHONY: down
down: ## Stop services
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) down

.PHONY: ps
ps: ## Display container status
	@cd $(DIR_DOCKER) && docker container ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

.PHONY: psa
psa: ## Display all container statuses
	@cd $(DIR_DOCKER) && docker container ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"

.PHONY: logs
logs: ## Display logs
	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) logs

.PHONY: system-prune-all
system-prune-all: ## Remove all unnecessary Docker resources
	@docker system prune -a --volumes


# ==============================
# Local Development Environment
# ==============================

# ---------- Prepare ----------

.PHONY: setup-dirs
setup-dirs: ## Create backend and frontend directories if they do not exist
	@mkdir -p $(DIR_BACKEND)
	@mkdir -p $(DIR_FRONTEND)

.PHONY: setup-nginx-log-files
setup-nginx-log-files: ## Create nginx log files if they do not exist
	@# Log files to check and create if not exist
	@LOG_FILES="backend_access.log frontend_access.log backend_error.log frontend_error.log"; \
	for log in $$LOG_FILES; do \
	  if [ ! -f $(DIR_DOCKER)/services/nginx/logs/$$log ]; then \
	    touch $(DIR_DOCKER)/services/nginx/logs/$$log; \
	  fi; \
	done

.PHONY: check-and-install
check-and-install: ## Check for required files and run appropriate installation commands
	@# Check if composer.json exists in backend directory and run composer-install if it does
	@if [ -f $(DIR_BACKEND)/composer.json ]; then \
	  make composer-install; \
	fi

	@# Check if package.json exists in frontend directory and run npm-install if it does
	@if [ -f $(DIR_FRONTEND)/package.json ]; then \
	  make npm-install; \
	fi

.PHONY: setup
setup: ## Setup environment
	@cd $(DIR_DOCKER) && cp -n .env.example .env || true
	@make setup-dirs
	@make setup-nginx-log-files
	@make build
	@make up
	@make check-and-install

# ---------- Install ----------

.PHONY: install-laravel
install-laravel: ## Install the latest Laravel in the backend container
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_BACKEND) \
	composer create-project --prefer-dist laravel/laravel .

.PHONY: composer-install
composer-install: ## Run composer install in the backend container
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_BACKEND) \
	composer install

.PHONY: install-next
install-next: ## Install the latest Next.js in the frontend container
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_FRONTEND) npx create-next-app@latest .

.PHONY: npm-install
npm-install: ## Run npm ci in the frontend container
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_FRONTEND) npm ci

# ---------- Container ----------

.PHONY: frontend-up
frontend-up: ## Start frontend, frontend-proxy services
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_UP_D) $(SERVICE_FRONTEND) $(SERVICE_FRONTEND_PROXY)

.PHONY: frontend-npm-run-dev
frontend-npm-run-dev: ## Run npm run dev in the frontend container
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_FRONTEND) npm run dev

.PHONY: backend-up
backend-up: ## Start backend, backend-proxy services
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_UP_D) $(SERVICE_BACKEND) $(SERVICE_BACKEND_PROXY)

# ---------- Enter the container ----------

.PHONY: frontend
frontend: ## Enter the frontend container
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_FRONTEND) bash

.PHONY: backend
backend: ## Enter the backend container
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_BACKEND) bash

.PHONY: mysql
mysql: ## Enter the mysql container
	@cd $(DIR_DOCKER) && \
	$(DOCKER_COMPOSE_EXEC) $(SERVICE_MYSQL) bash


# ============================
# Production Environment
# ============================

# .PHONY: prod-setup
# prod-setup: ## Setup for production environment
# 	@cd $(DIR_DOCKER) && cp -n .env.production.example .env || true
# 	@cd ../$(DIR_FRONTEND) && npm ci --production
# 	@cd ../$(DIR_BACKEND) && composer install --no-dev --optimize-autoloader

# .PHONY: prod-up
# prod-up: ## Setup and start the project for production environment
# 	@make prod-setup
# 	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) -f docker-compose.prod.yml up -d

# .PHONY: prod-down
# prod-down: ## Stop the project for production environment
# 	@cd $(DIR_DOCKER) && $(DOCKER_COMPOSE) -f docker-compose.prod.yml down
