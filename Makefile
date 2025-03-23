# Include environment variables
include .env

# Variables for color management
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

# Variable definitions
DOCKER_COMPOSE = docker compose
DOCKER_EXEC = docker compose exec -T
PHP_CONTAINER = php
MYSQL_CONTAINER = $(shell docker compose ps -q mysqldb 2>/dev/null)
WEB_ROOT = $(shell pwd)/web
APP_DIR ?= app
APP_ROOT = $(WEB_ROOT)/$(APP_DIR)
MYSQL_DUMPS_DIR = data/db/dumps
CURRENT_USER = $(shell whoami)
CURRENT_UID = $(shell id -u)
CURRENT_GID = $(shell id -g)

# Main commands
.PHONY: help init dev prod start stop restart status logs

# Internal target to check if the application directory exists
check-app-dir:
	@if [ ! -d "$(APP_ROOT)" ]; then \
		echo "${YELLOW}Directory '$(APP_DIR)' does not exist. Please update APP_DIR in .env or create the directory.${NC}"; \
		exit 1; \
	fi

.PHONY: ... db-dump db-restore db-connect php-connect ...

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
	@echo "  ${YELLOW}composer-script${NC}      Run Composer scripts (e.g., make composer-script SCRIPT=test ARGS=\"--verbose --filter=Class\")"
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
	@echo "  ${YELLOW}php-connect${NC}          Connect to PHP container shell"
	@echo "  ${YELLOW}gen-certs${NC}            Generate SSL certificates"
	@echo "  ${YELLOW}enable-ssl${NC}           Enable SSL in Nginx configuration"
	@echo "  ${YELLOW}env-clean${NC}            Clean environment resources"
	@echo "  ${YELLOW}env-reset${NC}            Reset environment (including volumes)"
	@echo "  ${YELLOW}apidoc${NC}               Generate API documentation"
	@echo ""
	@echo "${GREEN}Framework commands:${NC}"
	@echo "  ${YELLOW}install-symfony${NC}      Install Symfony framework"
	@echo "  ${YELLOW}install-laravel${NC}      Install Laravel framework"
	@echo ""
	@echo "${GREEN}Debugging commands:${NC}"
	@echo "  ${YELLOW}xdebug-check${NC}         Check Xdebug configuration"
	@echo "  ${YELLOW}xdebug-restart${NC}       Restart PHP container with Xdebug"
	@echo ""
	@echo "${GREEN}Application directory:${NC}"
	@echo "  Current application directory: ${YELLOW}$(APP_DIR)${NC}"
	@echo "  To change, update APP_DIR in .env file or use APP_DIR=<dir> make <command>"
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
	@if grep -q "PHP_TARGET=dev" .env; then \
		echo "${BLUE}Development environment detected, enabling PHPMyAdmin...${NC}"; \
		$(DOCKER_COMPOSE) --profile dev up -d; \
	else \
		$(DOCKER_COMPOSE) up -d; \
	fi
	@echo "${GREEN}Containers started!${NC}"
	@echo "${GREEN}Using application directory: $(APP_DIR)${NC}"

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
.PHONY: composer-dist composer-install composer-update composer-autoload composer-script test code-sniff phpmd

composer-dist: check-app-dir
	@if [ ! -f $(APP_ROOT)/composer.json ]; then \
		echo "${BLUE}Creating composer.json file in $(APP_DIR)...${NC}"; \
		mkdir -p $(APP_ROOT); \
		if [ -f "composer.json.dist" ]; then \
			cp composer.json.dist $(APP_ROOT)/composer.json; \
		elif [ -f "$(WEB_ROOT)/composer.json.dist" ]; then \
			cp $(WEB_ROOT)/composer.json.dist $(APP_ROOT)/composer.json; \
		else \
			echo "{}" > $(APP_ROOT)/composer.json; \
		fi; \
		echo "${GREEN}composer.json created!${NC}"; \
	else \
		echo "${YELLOW}composer.json already exists in $(APP_DIR).${NC}"; \
		echo "${YELLOW}If you want to reset it, please remove the file first.${NC}"; \
	fi

composer-install: check-app-dir
	@echo "${BLUE}Installing PHP dependencies in $(APP_DIR)...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer install -d /var/www/html/$(APP_DIR)
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Dependencies installed!${NC}"

composer-update: check-app-dir
	@echo "${BLUE}Updating PHP dependencies in $(APP_DIR)...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer update -d /var/www/html/$(APP_DIR)
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Dependencies updated!${NC}"

composer-autoload: check-app-dir
	@echo "${BLUE}Updating autoloader in $(APP_DIR)...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer dump-autoload -d /var/www/html/$(APP_DIR)
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Autoloader updated!${NC}"

# Composer script command with dynamic arguments
composer-script: check-app-dir
	@echo "${BLUE}Running Composer script in $(APP_DIR)...${NC}"
	@if [ -z "$(SCRIPT)" ]; then \
		echo "${YELLOW}Please specify a script name: make composer-script SCRIPT=your-script-name${NC}"; \
		echo "${YELLOW}Available scripts:${NC}"; \
		$(DOCKER_EXEC) $(PHP_CONTAINER) composer run-script --list -d /var/www/html/$(APP_DIR) 2>/dev/null || echo "${YELLOW}No scripts defined in composer.json${NC}"; \
		exit 1; \
	fi
	@echo "${BLUE}Executing: composer run-script $(SCRIPT) $(ARGS)${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) composer run-script $(SCRIPT) $(ARGS) -d /var/www/html/$(APP_DIR)
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Script execution completed!${NC}"

test: check-app-dir
	@echo "${BLUE}Running tests in $(APP_DIR)...${NC}"
	@if [ -f "$(APP_ROOT)/vendor/bin/phpunit" ]; then \
		$(DOCKER_EXEC) $(PHP_CONTAINER) ./$(APP_DIR)/vendor/bin/phpunit --colors=always --configuration ./$(APP_DIR)/; \
	else \
		echo "${YELLOW}PHPUnit not found in $(APP_DIR). Please run composer-install first.${NC}"; \
		exit 1; \
	fi
	@$(MAKE) reset-owner dir=$(APP_ROOT)
	@echo "${GREEN}Tests completed!${NC}"

code-sniff: check-app-dir
	@echo "${BLUE}Checking code according to PSR2 in $(APP_DIR)...${NC}"
	@if [ -f "$(APP_ROOT)/vendor/bin/phpcs" ]; then \
		$(DOCKER_EXEC) $(PHP_CONTAINER) ./$(APP_DIR)/vendor/bin/phpcs -v --standard=PSR2 $(APP_DIR)/src; \
	else \
		echo "${YELLOW}PHP_CodeSniffer not found in $(APP_DIR). Please run composer-install first.${NC}"; \
		exit 1; \
	fi
	@echo "${GREEN}Check completed!${NC}"

phpmd: check-app-dir
	@echo "${BLUE}Analyzing code with PHP Mess Detector in $(APP_DIR)...${NC}"
	@if [ -f "$(APP_ROOT)/vendor/bin/phpmd" ]; then \
		$(DOCKER_EXEC) $(PHP_CONTAINER) \
		./$(APP_DIR)/vendor/bin/phpmd \
		./$(APP_DIR)/src text cleancode,codesize,controversial,design,naming,unusedcode; \
	else \
		echo "${YELLOW}PHP Mess Detector not found in $(APP_DIR). Please run composer-install first.${NC}"; \
		exit 1; \
	fi
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
	elif [ ! -f "$(MYSQL_DUMPS_DIR)/db.sql" ]; then \
		echo "${YELLOW}Backup file not found at $(MYSQL_DUMPS_DIR)/db.sql!${NC}"; \
	else \
		echo "${YELLOW}WARNING: This will overwrite existing database data!${NC}"; \
		echo "${YELLOW}Are you sure you want to continue? [y/N] ${NC}"; \
		read -r confirmation; \
		if [ "$$confirmation" = "y" ] || [ "$$confirmation" = "Y" ]; then \
			docker exec -i $(MYSQL_CONTAINER) mysql -u"$${MYSQL_ROOT_USER}" -p"$${MYSQL_ROOT_PASSWORD}" < $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null; \
			echo "${GREEN}Database restored!${NC}"; \
		else \
			echo "${BLUE}Operation canceled.${NC}"; \
		fi \
	fi

db-connect:
	@echo "${BLUE}Connecting to MySQL shell...${NC}"
	@if [ -z "$(MYSQL_CONTAINER)" ]; then \
		echo "${YELLOW}MySQL container is not running!${NC}"; \
	else \
		docker exec -it $(MYSQL_CONTAINER) mysql -uroot -p${MYSQL_ROOT_PASSWORD}; \
	fi

# Utility commands
.PHONY: php-connect gen-certs enable-ssl env-clean env-reset apidoc reset-owner

php-connect:
	@echo "${BLUE}Connexion au shell du conteneur PHP...${NC}"
	@if ! $(DOCKER_COMPOSE) ps --services --filter "status=running" | grep -q $(PHP_CONTAINER); then \
		echo "${YELLOW}Le conteneur PHP n'est pas en cours d'exécution!${NC}"; \
		exit 1; \
	fi
	@$(DOCKER_COMPOSE) exec -it $(PHP_CONTAINER) bash
	@echo "${GREEN}Session shell du conteneur PHP terminée.${NC}"

gen-certs:
	@echo "${BLUE}Generating SSL certificates...${NC}"
	@docker build -t ssl-generator docker/ssl
	@docker run --rm -v $(shell pwd)/etc/ssl:/certificates \
		-e SERVER=${NGINX_HOST} \
		-e COUNTRY=${NGINX_SSL_COUNTRY} \
		-e STATE=${NGINX_SSL_STATE} \
		-e LOCALITY=${NGINX_SSL_LOCALITY} \
		-e ORGANIZATION=${NGINX_SSL_ORGANIZATION} \
		-e ORGANIZATIONAL_UNIT=${NGINX_SSL_UNIT} \
		-e EMAIL=${NGINX_SSL_EMAIL} \
		-e CERT_EXPIRY=${NGINX_SSL_DAYS} \
		-e KEY_SIZE=${NGINX_SSL_KEY_SIZE} \
		ssl-generator
	@$(MAKE) reset-owner dir=$(shell pwd)/etc/ssl
	@echo "${GREEN}Certificates generated!${NC}"

enable-ssl:
	@echo "${BLUE}Enabling SSL in Nginx configuration...${NC}"
	@docker run --rm \
		-v $(PWD)/etc/nginx:/etc/nginx \
		alpine:latest \
		sh -c 'apk add --no-cache sed && sed -i "/^# server {/,/^# }/ s/^# //" /etc/nginx/default.template.conf && sed -i "/^#[[:space:]]*$$/s/^#//" /etc/nginx/default.template.conf'
	@$(MAKE) restart
	@echo "${GREEN}SSL has been enabled. Access your site at https://${NGINX_HOST}:3000${NC}"

env-clean:
	@echo "${BLUE}Cleaning environment resources...${NC}"
	@echo "${YELLOW}This will remove unused resources related to this project${NC}"
	@echo "${YELLOW}Are you sure you want to continue? [y/N] ${NC}"
	@read -r confirmation; \
	if [ "$$confirmation" = "y" ] || [ "$$confirmation" = "Y" ]; then \
		echo "${BLUE}Removing unused project resources...${NC}"; \
		docker container prune -f --filter "label=com.docker.compose.project=${PROJECT_NAME:-docker_nginx_php_mysql}"; \
		docker network prune -f --filter "label=com.docker.compose.project=${PROJECT_NAME:-docker_nginx_php_mysql}"; \
		rm -rf .phpdoc; \
		rm -rf etc/ssl/*; \
		echo "${GREEN}Environment cleaned!${NC}"; \
	else \
		echo "${BLUE}Operation canceled.${NC}"; \
	fi

env-reset: stop
	@echo "${YELLOW}WARNING: This will reset the project environment including all volumes and data!${NC}"
	@echo "${YELLOW}Are you sure you want to continue? [y/N] ${NC}"
	@read -r confirmation; \
	if [ "$$confirmation" = "y" ] || [ "$$confirmation" = "Y" ]; then \
		echo "${BLUE}Resetting project environment...${NC}"; \
		docker container prune -f --filter "label=com.docker.compose.project=${PROJECT_NAME:-docker_nginx_php_mysql}"; \
		docker network prune -f --filter "label=com.docker.compose.project=${PROJECT_NAME:-docker_nginx_php_mysql}"; \
		docker volume rm $(shell docker volume ls -q -f name=${PROJECT_NAME:-docker_nginx_php_mysql}) 2>/dev/null || true; \
		rm -rf .phpdoc; \
		rm -rf etc/ssl/*; \
		rm -rf $(MYSQL_DUMPS_DIR)/*; \
		echo "${GREEN}Environment reset completed!${NC}"; \
	else \
		echo "${BLUE}Operation canceled.${NC}"; \
	fi

apidoc: check-app-dir
	@echo "${BLUE}Generating API documentation for $(APP_DIR)...${NC}"
	@if [ ! -d "$(APP_ROOT)/src" ]; then \
		echo "${YELLOW}Source directory $(APP_DIR)/src not found!${NC}"; \
		exit 1; \
	fi
	@docker run --rm -v $(shell pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/$(APP_DIR)/src -t /data/web/$(APP_DIR)/doc
	@$(MAKE) reset-owner dir=$(APP_ROOT)/doc
	@echo "${GREEN}Documentation generated!${NC}"

apidocs-generate:
	@echo "${BLUE}Generating API documentation for $(APP_DIR)...${NC}"
	@if [ ! -d "$(APP_ROOT)/src" ]; then \
		echo "${YELLOW}Source directory $(APP_DIR)/src not found!${NC}"; \
		exit 1; \
	fi
	@mkdir -p ./docs/api/html
	@docker run --rm -v $(shell pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/$(APP_DIR)/src -t /data/docs/api/html
	@$(MAKE) reset-owner dir=./docs/api
	@echo "${GREEN}Documentation generated in ./docs/api/html!${NC}"

reset-owner:
	@chown -R $(CURRENT_USER):$(CURRENT_GID) $(dir) 2>/dev/null || true

# Framework commands
.PHONY: install-symfony install-laravel

install-symfony:
	@echo "${BLUE}Installing Symfony framework...${NC}"
	@if [ -d "$(WEB_ROOT)/symfony-app" ]; then \
		echo "${YELLOW}WARNING: Directory 'symfony-app' already exists!${NC}"; \
		echo "${YELLOW}Please remove or rename the existing directory before installing Symfony.${NC}"; \
		exit 1; \
	fi
	@$(DOCKER_EXEC) $(PHP_CONTAINER) bash -c "cd /var/www/html && composer create-project symfony/skeleton symfony-app"
	@$(MAKE) reset-owner dir=$(WEB_ROOT)/symfony-app
	@echo "${GREEN}Symfony installed in ./web/symfony-app!${NC}"
	@echo "${YELLOW}To configure your environment for Symfony, update these variables in .env:${NC}"
	@echo "${YELLOW}APP_WORKSPACE=symfony${NC}"
	@echo "${YELLOW}APP_DIR=symfony-app${NC}"
	@echo "${YELLOW}Then restart the containers with: make restart${NC}"

install-laravel:
	@echo "${BLUE}Installing Laravel framework...${NC}"
	@if [ -d "$(WEB_ROOT)/laravel-app" ]; then \
		echo "${YELLOW}WARNING: Directory 'laravel-app' already exists!${NC}"; \
		echo "${YELLOW}Please remove or rename the existing directory before installing Laravel.${NC}"; \
		exit 1; \
	fi
	@$(DOCKER_EXEC) $(PHP_CONTAINER) bash -c "cd /var/www/html && composer create-project laravel/laravel laravel-app"
	@$(MAKE) reset-owner dir=$(WEB_ROOT)/laravel-app
	@echo "${GREEN}Laravel installed in ./web/laravel-app!${NC}"
	@echo "${YELLOW}To configure your environment for Laravel, update these variables in .env:${NC}"
	@echo "${YELLOW}APP_WORKSPACE=laravel${NC}"
	@echo "${YELLOW}APP_DIR=laravel-app${NC}"
	@echo "${YELLOW}Then restart the containers with: make restart${NC}"

# Debugging commands
.PHONY: xdebug-check xdebug-restart

xdebug-check:
	@echo "${BLUE}Checking Xdebug configuration...${NC}"
	@$(DOCKER_EXEC) $(PHP_CONTAINER) php -v
	@$(DOCKER_EXEC) $(PHP_CONTAINER) php -i | grep -i xdebug
	@echo "${GREEN}Xdebug check completed!${NC}"

xdebug-restart:
	@echo "${BLUE}Restarting PHP container with Xdebug...${NC}"
	@$(DOCKER_COMPOSE) restart php
	@echo "${GREEN}PHP container restarted!${NC}"
	@$(MAKE) xdebug-check