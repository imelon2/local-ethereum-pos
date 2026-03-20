GETH_COMPOSE_RUN=docker compose

.PHONY: run re-run geth geth/force pectra pectra/force pectra/down dencun dencun/down dencun/force fusaka fusaka/down fusaka/force

run: geth

re-run: geth/force

geth:
	@echo Building geth node...
	@$(GETH_COMPOSE_RUN) up -d > /dev/null 2>&1

geth/force:
	@echo Down geth node...
	@$(GETH_COMPOSE_RUN) down > /dev/null 2>&1
	@echo Reset geth node DB...
	@sudo ./launcher.sh clean > /dev/null 2>&1
	@echo Re-Building geth node...
	@$(GETH_COMPOSE_RUN) up -d > /dev/null 2>&1

pectra:
	@echo Building pectra node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./pectra/docker-compose.yml up -d > /dev/null 2>&1

pectra/down:
	@echo Down pectra node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./pectra/docker-compose.yml down > /dev/null 2>&1

pectra/force:
	@echo Down pectra node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./pectra/docker-compose.yml down > /dev/null 2>&1
	@echo Reset pectra node DB...
	@./launcher.sh clean --version pectra
	@echo Re-Building pectra node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./pectra/docker-compose.yml up -d > /dev/null 2>&1

dencun:
	@echo Building dencun node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./dencun/docker-compose.yml up -d > /dev/null 2>&1

dencun/down:
	@echo Down dencun node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./dencun/docker-compose.yml down > /dev/null 2>&1

dencun/force:
	@echo Down dencun node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./dencun/docker-compose.yml down > /dev/null 2>&1
	@echo Reset dencun node DB...
	@./launcher.sh clean --version dencun
	@echo Re-Building dencun node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./dencun/docker-compose.yml up -d > /dev/null 2>&1

fusaka:
	@echo Building fusaka node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./fusaka/docker-compose.yml up -d > /dev/null 2>&1

fusaka/down:
	@echo Down fusaka node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./fusaka/docker-compose.yml down > /dev/null 2>&1

fusaka/force:
	@echo Down fusaka node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./fusaka/docker-compose.yml down > /dev/null 2>&1
	@echo Reset fusaka node DB...
	@./launcher.sh clean --version fusaka
	@echo Re-Building fusaka node...
	@DOCKER_UID=$$(id -u) DOCKER_GID=$$(id -g) $(GETH_COMPOSE_RUN) -f ./fusaka/docker-compose.yml up -d > /dev/null 2>&1
