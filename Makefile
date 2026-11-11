# Use bash for deployment compatibility
SHELL := /bin/bash

.DEFAULT_GOAL := help

# Phony targets
.PHONY: help \
	web api db dev \
	docker-web docker-api docker-db docker-up docker-down docker-db-nuke docker-nuke \
	openapi-regen \
	build test lint fmt clean

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ==============================================================================
# Native Local Targets
# ==============================================================================

web: ## Start Angular 22+ frontend natively ($root/web)
	@echo "Starting Angular 22+ frontend natively..."
	@if [ ! -d "web/node_modules" ]; then \
		echo "Installing web dependencies..."; \
		npm --prefix web ci; \
	fi
	npm --prefix web start

api: ## Start .NET 10 Modular-Monolith API natively ($root/api)
	@echo "Starting .NET 10 Modular-Monolith API natively..."
	@if [ -d "api/src/PersonalSite.Api" ]; then \
		dotnet watch --project api/src/PersonalSite.Api; \
	elif [ -d "api" ] && ls api/*.sln 1> /dev/null 2>&1; then \
		dotnet watch --project api; \
	else \
		echo "api/ project not yet scaffolded (pending Part 2.2 #39)."; \
		exit 1; \
	fi

db: ## Start local PostgreSQL 17 instance
	@echo "Starting PostgreSQL 17..."
	@if command -v pg_isready >/dev/null 2>&1 && pg_isready -q -h localhost -p 5432 -U postgres; then \
		echo "PostgreSQL is already running on port 5432."; \
	else \
		echo "Starting PostgreSQL 17 and Mailpit via Docker Compose..."; \
		docker compose up -d db mailpit; \
	fi

dev: ## Start full stack natively (db + api + web)
	@echo "Starting full stack natively (db + api + web)..."
	@$(MAKE) db
	@if [ -d "api/src/PersonalSite.Api" ]; then \
		$(MAKE) -j 2 api web; \
	else \
		$(MAKE) web; \
	fi

# ==============================================================================
# Docker Counterpart Targets
# ==============================================================================

docker-web: ## Run Angular 22+ frontend container via Docker Compose
	docker compose up --build web

docker-api: ## Run .NET 10 API container via Docker Compose
	@if [ -d "api" ] && [ -f "api/Dockerfile" ]; then \
		docker compose up --build api; \
	else \
		echo "api/Dockerfile not yet present (pending Part 2.2 #39)."; \
		exit 1; \
	fi

docker-db: ## Run PostgreSQL 17 + Mailpit containers via Docker Compose
	docker compose up -d db mailpit

docker-up: ## Run full stack (db + api + web) in Docker Compose
	@if [ -d "api" ] && [ -f "api/Dockerfile" ]; then \
		docker compose up --build; \
	else \
		echo "api/Dockerfile not yet present (pending Part 2.2 #39). Starting db, mailpit, and web..."; \
		docker compose up --build db mailpit web; \
	fi

docker-down: ## Stop running Docker Compose containers (preserves volumes)
	docker compose down

docker-db-nuke: ## Destroy only the PostgreSQL container & data volume, then restart clean db
	docker compose stop db
	docker compose rm -f -v db
	docker volume rm -f postgres_data personal-site_postgres_data 2>/dev/null || true
	docker compose up -d db

docker-nuke: ## Destroy all project containers, volumes, networks, local images & orphans
	docker compose down -v --rmi local --remove-orphans

# ==============================================================================
# Codegen & Quality Targets
# ==============================================================================

openapi-regen: ## Build .NET 10 OpenAPI 3.1 spec (api/openapi/v1.json) & regenerate Angular TypeScript client
	@echo "Generating OpenAPI 3.1 spec and Angular client..."
	@if [ -d "api/src/PersonalSite.Api" ]; then \
		dotnet build api/src/PersonalSite.Api; \
	else \
		echo "api/ not yet scaffolded (pending Part 2.3 #40)."; \
	fi
	@if [ -f "api/openapi/v1.json" ]; then \
		echo "Regenerating Angular TypeScript client via @hey-api/openapi-ts..."; \
		npm --prefix web run codegen:api || npx --prefix web @hey-api/openapi-ts -i ../api/openapi/v1.json -o src/app/core/api; \
	fi

build: ## Build production bundles for web and api
	@echo "Building web production bundle..."
	npm --prefix web run build
	@if [ -d "api" ] && ls api/*.sln 1> /dev/null 2>&1; then \
		echo "Building .NET 10 API Release bundle..."; \
		dotnet build -c Release api/; \
	fi

test: ## Run unit and integration tests
	@echo "Running web unit tests..."
	npm --prefix web run test
	@if [ -d "api" ] && ls api/*.sln 1> /dev/null 2>&1; then \
		echo "Running .NET 10 API tests..."; \
		dotnet test api/; \
	fi

lint: ## Run linters across web and api
	@echo "Running web linting..."
	npm --prefix web run lint
	@if [ -d "api" ] && ls api/*.sln 1> /dev/null 2>&1; then \
		echo "Running .NET 10 code analysis..."; \
		dotnet format --verify-no-changes api/; \
	fi

fmt: ## Format code across web and api
	@echo "Formatting web code..."
	npm --prefix web run format
	@if [ -d "api" ] && ls api/*.sln 1> /dev/null 2>&1; then \
		echo "Formatting .NET 10 code..."; \
		dotnet format api/; \
	fi

clean: ## Remove build artifacts and caches
	@echo "Cleaning artifacts and caches..."
	rm -rf web/dist web/.angular dist .eslintcache
	@if [ -d "api" ]; then \
		find api -type d \( -name "bin" -o -name "obj" \) -exec rm -rf {} + 2>/dev/null || true; \
	fi
