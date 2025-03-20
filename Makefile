# Include environment variables
include .env

# Variables pour la gestion des couleurs
ifndef NOCOLOR
  GREEN = \033[0;32m
  YELLOW = \033[0;33m
  BLUE = \033[0;34m
  NC = \033[0m # No Color
else
  GREEN =
  YELLOW =
  BLUE =
  NC =
endif

# Définition des variables
DOCKER_COMPOSE = docker-compose
DOCKER_EXEC = docker-compose exec -T
PHP_CONTAINER = php
MYSQL_CONTAINER = $(shell docker-compose ps -q mysqldb 2>/dev/null)
WEB_ROOT = $(shell pwd)/web
APP_ROOT = $(WEB_ROOT)/app
MYSQL_DUMPS_DIR = data/db/dumps
CURRENT_USER = $(shell whoami)
CURRENT_UID = $(shell id -u)
CURRENT_GID = $(shell id -g)

# Commandes principales
.PHONY: help init dev prod start stop restart status logs

help:
	@echo ""
	@echo "${BLUE}Docker Nginx PHP MySQL - Version 2.0${NC}"
	@echo ""
	@echo "${GREEN}Usage:${NC} make ${YELLOW}<command>${NC}"
	@echo ""
	@echo "${GREEN}Environment commands:${NC}"
	@echo "  ${YELLOW}init${NC}                 Initialize the project"
	@echo "  ${YELLOW}dev${NC}                  Set up development environment"
	@echo "  ${YELLOW}prod${NC}                 Set up production environment"
	@echo "  ${YELLOW}start${NC}                Start all containers"
	@echo "  ${YELLOW}stop${NC}                 Stop all containers"
	@echo "  ${YELLOW}restart${NC}              Restart all containers"
	@echo "  ${YELLOW}status${NC}               Display containers status"
	@echo "  ${YELLOW}logs${NC}                 Follow log output"
	@echo ""
	@echo "${GREEN}Development commands:${NC}"
	@echo "  ${YELLOW}composer-install${NC}     Install PHP dependencies with Composer"
	@echo "  ${YELLOW}composer-update${NC}      Update PHP dependencies with Composer"
	@echo "  ${YELLOW}composer-autoload${NC}    Update autoloader"
	@echo "  ${YELLOW}test${NC}                 Run tests"
	@echo "  ${YELLOW}code-sniff${NC}           Check code with PHP Code Sniffer (PSR2)"
	@echo "  ${YELLOW}phpmd${NC}                Analyze code with PHP Mess Detector"
	@echo ""
	@echo "${GREEN}Database commands:${NC}"
	@echo "  ${YELLOW}db-dump${NC}              Create backup of all databases"
	@echo "  ${YELLOW}db-restore${NC}           Restore backup of all databases"
	@echo "  ${YELLOW}db-connect${NC}           Connect to MySQL shell"
	@echo ""
	@echo "${GREEN}Utility commands:${NC}"
	@echo "  ${YELLOW}gen-certs${NC}            Generate SSL certificates"
	@echo "  ${YELLOW}clean${NC}                Clean directories for reset"
	@echo "  ${YELLOW}apidoc${NC}               Generate API documentation"
	@echo ""
	@echo "${GREEN}Framework commands:${NC}"
	@echo "  ${YELLOW}install-symfony${NC}      Install Symfony framework"
	@echo "  ${YELLOW}install-laravel${NC}      Install Laravel framework"
	@echo ""

init: check-env composer-dist composer-install
	@echo "${GREEN}Project initialized successfully!${NC}"

check-env:
	@if [ ! -f .env ]; then \
		echo "${BLUE}Creating default .env file...${NC}"; \
		cp .env.dev .env; \
		echo "${GREEN}.env file created!${NC}"; \
	fi

dev:
	@echo "${BLUE}Setting up development environment...${NC}"
	@cp -f .env.dev .env
	@$(MAKE) restart
	@echo "${GREEN}Development environment is ready!${NC}"

prod:
	@echo "${BLUE}Setting up production environment...${NC}"
	@cp -f .env.prod .env
	@$(MAKE) restart
	@echo "${GREEN}Production environment is ready!${NC}"
	@echo "${YELLOW}Note: This is a simulated production environment. For real production, additional configurations may be needed.${NC}"

start:
	@echo "${BLUE}Starting containers...${NC}"
	@$(DOCKER_COMPOSE) up -d
	@echo "${GREEN}Containers started!${NC}"

stop:
	@echo "${BLUE}Stopping containers...${NC}"
	@$(DOCKER_COMPOSE) down
	@echo "${GREEN}Containers stopped!${NC}"

restart: stop start

status:
	@$(DOCKER_COMPOSE) ps

logs:
	@$(DOCKER_COMPOSE) logs -f

# Development commands
.PHONY: composer-dist composer-install composer-update composer-autoload test code-sniff phpmd

composer-dist:
	@if [ ! -f $(APP_ROOT)/composer.json ]; then \
		echo "${BLUE}Creating composer.json file...${NC}"; \
		cp $(APP_ROOT)/composer.json.dist $(APP_ROOT)/composer.json; \
		echo "${GREEN}composer.json created!${NC}"; \
	fi

composer-install:
	@echo "${BLUE}Installing PHP dependencies...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer install -d /var/www/html/app
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Dependencies installed!${NC}"

composer-update:
	@echo "${BLUE}Updating PHP dependencies...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer update -d /var/www/html/app
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Dependencies updated!${NC}"

composer-autoload:
	@echo "${BLUE}Updating autoloader...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer dump-autoload -d /var/www/html/app
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Autoloader updated!${NC}"

test: code-sniff
	@echo "${BLUE}Running tests...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) ./app/vendor/bin/phpunit --colors=always --configuration ./app/
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Tests completed!${NC}"

code-sniff:
	@echo "${BLUE}Checking code according to PSR2...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) ./app/vendor/bin/phpcs -v --standard=PSR2 app/src
	@echo "${GREEN}Check completed!${NC}"

phpmd:
	@echo "${BLUE}Analyzing code with PHP Mess Detector...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) \
	./app/vendor/bin/phpmd \
	./app/src text cleancode,codesize,controversial,design,naming,unusedcode
	@echo "${GREEN}Analysis completed!${NC}"

# Database commands
.PHONY: db-dump db-restore db-connect

db-dump:
	@echo "${BLUE}Creating database backup...${NC}"
	@mkdir -p $(MYSQL_DUMPS_DIR)
	@if [ -z "$(MYSQL_CONTAINER)" ]; then \
		echo "${YELLOW}MySQL container is not running!${NC}"; \
	else \
		docker exec $(MYSQL_CONTAINER) mysqldump --all-databases -u"$${MYSQL_ROOT_USER}" -p"$${MYSQL_ROOT_PASSWORD}" > $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null; \
		$(MAKE) reset-owner dir=$(MYSQL_DUMPS_DIR); \
		echo "${GREEN}Backup created in $(MYSQL_DUMPS_DIR)/db.sql!${NC}"; \
	fi

db-restore:
	@echo "${BLUE}Restoring database...${NC}"
	@if [ -z "$(MYSQL_CONTAINER)" ]; then \
		echo "${YELLOW}MySQL container is not running!${NC}"; \
	else \
		docker exec -i $(MYSQL_CONTAINER) mysql -u"$${MYSQL_ROOT_USER}" -p"$${MYSQL_ROOT_PASSWORD}" < $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null; \
		echo "${GREEN}Database restored!${NC}"; \
	fi

db-connect:
	@echo "${BLUE}Connecting to MySQL shell...${NC}"
	@if [ -z "$(MYSQL_CONTAINER)" ]; then \
		echo "${YELLOW}MySQL container is not running!${NC}"; \
	else \
		docker exec -it $(MYSQL_CONTAINER) mysql -u"$${MYSQL_ROOT_USER}" -p"$${MYSQL_ROOT_PASSWORD}"; \
	fi

# Utility commands
.PHONY: gen-certs clean apidoc reset-owner

gen-certs:
	@echo "${BLUE}Generating SSL certificates...${NC}"
	@docker build -t ssl-generator docker/ssl
	@docker run --rm -v $(shell pwd)/etc/ssl:/certificates \
		-e SERVER=${NGINX_HOST} \
		-e COUNTRY=${SSL_COUNTRY} \
		-e STATE=${SSL_STATE} \
		-e LOCALITY=${SSL_LOCALITY} \
		-e ORGANIZATION=${SSL_ORGANIZATION} \
		-e ORGANIZATIONAL_UNIT=${SSL_UNIT} \
		-e EMAIL=${SSL_EMAIL} \
		-e CERT_EXPIRY=${SSL_DAYS} \
		-e KEY_SIZE=${SSL_KEY_SIZE} \
		ssl-generator
	@$(MAKE) reset-owner dir=$(shell pwd)/etc/ssl
	@echo "${GREEN}Certificates generated!${NC}"

clean:
	@echo "${BLUE}Cleaning directories...${NC}"
	@rm -Rf data/db/mysql/*
	@rm -Rf $(MYSQL_DUMPS_DIR)/*
	@rm -Rf $(APP_ROOT)/vendor
	@rm -Rf $(APP_ROOT)/composer.lock
	@rm -Rf $(APP_ROOT)/doc
	@rm -Rf $(APP_ROOT)/report
	@rm -Rf etc/ssl/*
	@echo "${GREEN}Clean completed!${NC}"

apidoc:
	@echo "${BLUE}Generating API documentation...${NC}"
	@docker run --rm -v $(shell pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/app/src -t /data/web/app/doc
	@$(MAKE) reset-owner dir=$(APP_ROOT)/doc
	@echo "${GREEN}Documentation generated!${NC}"

reset-owner:
	@chown -R $(CURRENT_USER):$(CURRENT_GID) $(dir) 2>/dev/null || true

# Framework commands
.PHONY: install-symfony install-laravel

install-symfony:
	@echo "${BLUE}Installing Symfony...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer create-project symfony/skeleton ./symfony-app
	@echo "${GREEN}Symfony installed!${NC}"
	@echo "${YELLOW}Don't forget to adjust your Nginx configuration.${NC}"

install-laravel:
	@echo "${BLUE}Installing Laravel...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer create-project laravel/laravel ./laravel-app
	@echo "${GREEN}Laravel installed!${NC}"
	@echo "${YELLOW}Don't forget to adjust your Nginx configuration.${NC}"