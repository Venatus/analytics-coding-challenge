.PHONY: up down restart logs dbt-deps dbt-run dbt-test dbt-docs dbt-compile dbt-shell clickhouse-client clean help

# Detect docker compose command (plugin vs standalone)
DOCKER_COMPOSE := $(shell docker compose version >/dev/null 2>&1 && echo "docker compose" || echo "docker-compose")

# ---------------------------------------------------------------------------
# Infrastructure
# ---------------------------------------------------------------------------

## Start all services (ClickHouse, Trino, Lightdash, etc.)
up:
	$(DOCKER_COMPOSE) up -d --build
	@echo ""
	@echo "=========================================="
	@echo "  Services starting up..."
	@echo "=========================================="
	@echo "  ClickHouse HTTP:   http://localhost:8123/play"
	@echo "  Trino:             http://localhost:8085"
	@echo "  Lightdash:         http://localhost:$${LIGHTDASH_PORT:-8880}"
	@echo "  MinIO Console:     http://localhost:9001"
	@echo "=========================================="
	@echo ""
	@echo "  Lightdash login:   admin@lightdash.com / admin123!"
	@echo ""
	@echo "  Wait ~60s for all services to initialise."
	@echo "  Then run: make dbt-deps && make dbt-run"
	@echo ""

## Stop all services
down:
	$(DOCKER_COMPOSE) down

## Restart all services
restart: down up

## Follow logs for all services
logs:
	$(DOCKER_COMPOSE) logs -f

# ---------------------------------------------------------------------------
# dbt commands (run inside Docker)
# ---------------------------------------------------------------------------

## Install dbt packages
dbt-deps:
	$(DOCKER_COMPOSE) run --rm --build dbt deps

## Run all dbt models
dbt-run:
	$(DOCKER_COMPOSE) run --rm dbt run

## Run all dbt tests
dbt-test:
	$(DOCKER_COMPOSE) run --rm dbt test

## Compile dbt project (generates manifest.json for Lightdash)
dbt-compile:
	$(DOCKER_COMPOSE) run --rm dbt compile

## Generate dbt docs
dbt-docs:
	$(DOCKER_COMPOSE) run --rm dbt docs generate
	@echo "Docs generated in dbt/target/"
	@echo "To serve locally: cd dbt && dbt docs serve"

## Open a shell in the dbt container
dbt-shell:
	$(DOCKER_COMPOSE) run --rm --entrypoint /bin/bash dbt

# ---------------------------------------------------------------------------
# Database access
# ---------------------------------------------------------------------------

## Open ClickHouse client
clickhouse-client:
	$(DOCKER_COMPOSE) exec clickhouse clickhouse-client

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

## Remove all Docker volumes and rebuild from scratch
clean:
	$(DOCKER_COMPOSE) down -v
	rm -rf dbt/target dbt/dbt_packages dbt/logs
	@echo "Cleaned all volumes and build artifacts."

## Show available commands
help:
	@echo "Available targets:"
	@echo ""
	@grep -E '^## ' Makefile | sed 's/^## /  /'
	@echo ""
	@echo "Usage: make <target>"
