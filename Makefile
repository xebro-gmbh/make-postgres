#--------------------------
# xebro GmbH - postgres - 1.0.0
#--------------------------

DB_FILENAME=$(shell date +"%Y%m%d%H%M%S")
DUMP ?=

POSTGRES_DIR := $(patsubst $(XO_ROOT_DIR)/%,./%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
POSTGRES := $(notdir $(patsubst %/,%,$(POSTGRES_DIR)))

postgres.bash: ## Execute bash inside database image
	@${DOCKER_COMPOSE} exec postgres bash

postgres.logs: ## Show postgres container logs
	@${DOCKER_COMPOSE} logs -f postgres

postgres.restart: ## Show postgres container logs
	@${DOCKER_COMPOSE} down postgres
	@${DOCKER_COMPOSE} up -d postgres

postgres.console: ## Run mysql console
	${DOCKER_COMPOSE} exec postgres psql ${POSTGRES_DB} --username=${POSTGRES_USER}

postgres.export: ## create database backup from current db
	@mkdir -p ${XO_MODULES_DIR}/var
	${DOCKER_COMPOSE} exec postgres pg_dump symfony --username=app --clean --create   > "${XO_MODULES_DIR}/var/${DB_FILENAME}.sql"

postgres.import: ## import database dump into current db (DUMP=path/to/dump.sql[.gz])
	@if [ -z "${DUMP}" ]; then echo "Usage: make postgres.import DUMP=path/to/dump.sql[.gz]"; exit 1; fi
	@if [ ! -f "${DUMP}" ]; then echo "Dump not found: ${DUMP}"; exit 1; fi
	@if echo "${DUMP}" | grep -qE '\.gz$$'; then \
		gzip -dc "${DUMP}" | ${DOCKER_COMPOSE} exec -T postgres psql ${POSTGRES_DB} --username=${POSTGRES_USER} --set=ON_ERROR_STOP=on; \
	else \
		${DOCKER_COMPOSE} exec -T postgres psql ${POSTGRES_DB} --username=${POSTGRES_USER} --set=ON_ERROR_STOP=on < "${DUMP}"; \
	fi

postgres.install:
	$(call headline,"Installing ${COMPONENT}")
	$(call ensure_env_vars,".env","${POSTGRES_DIR}config/.env")


install: postgres.install
