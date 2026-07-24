# Makefile for Docker Nginx PHP Composer MariaDB

include .env

# MariaDB
MARIADB_DUMPS_DIR=data/db/dumps

help:
	@echo ""
	@echo "usage: make COMMAND"
	@echo ""
	@echo "Commands:"
	@echo "  apidoc              Generate documentation of API"
	@echo "  code-sniff          Check the API with PHP Code Sniffer (PSR2)"
	@echo "  clean               Clean directories for reset"
	@echo "  composer-up         Update PHP dependencies with composer"
	@echo "  docker-start        Create and start containers"
	@echo "  docker-stop         Stop and clear all services"
	@echo "  gen-certs           Generate SSL certificates"
	@echo "  logs                Follow log output"
	@echo "  mariadb-dump        Create backup of MariaDB databases"
	@echo "  mariadb-restore     Restore backup of MariaDB databases"
	@echo "  postgres-dump       Create backup of PostgreSQL databases"
	@echo "  postgres-restore    Restore backup of PostgreSQL databases"
	@echo "  phpmd               Analyse the API with PHP Mess Detector"
	@echo "  test                Test application"

init:
	@$(shell cp -n $(shell pwd)/web/app/composer.json.dist $(shell pwd)/web/app/composer.json 2> /dev/null)

apidoc:
	@docker run --rm -v $(shell pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/app/src -t /data/web/app/doc
	@make resetOwner

clean:
	@rm -Rf data/db/mariadb/*
	@rm -Rf data/db/postgres/*
	@rm -Rf $(MARIADB_DUMPS_DIR)/*
	@rm -Rf web/app/vendor
	@rm -Rf web/app/composer.lock
	@rm -Rf web/app/doc
	@rm -Rf web/app/report
	@rm -Rf etc/ssl/*

code-sniff:
	@echo "Checking the standard code..."
	@docker-compose exec -T php ./app/vendor/bin/phpcs -v --standard=PSR2 app/src

composer-up:
	@docker run --rm -v $(shell pwd)/web/app:/app composer update

docker-start: init
	docker-compose up -d

docker-stop:
	@docker-compose down -v
	@make clean

gen-certs:
	@docker run --rm -v $(shell pwd)/etc/ssl:/certificates -e "SERVER=$(NGINX_HOST)" jacoelho/generate-certificate

logs:
	@docker-compose logs -f

mariadb-dump:
	@mkdir -p $(MARIADB_DUMPS_DIR)
	@docker exec $(shell docker-compose ps -q mariadb) mariadb-dump --all-databases -u"$(MARIADB_ROOT_USER)" -p"$(MARIADB_ROOT_PASSWORD)" > $(MARIADB_DUMPS_DIR)/mariadb.sql 2>/dev/null
	@make resetOwner

mariadb-restore:
	@docker exec -i $(shell docker-compose ps -q mariadb) mariadb -u"$(MARIADB_ROOT_USER)" -p"$(MARIADB_ROOT_PASSWORD)" < $(MARIADB_DUMPS_DIR)/mariadb.sql 2>/dev/null

postgres-dump:
	@mkdir -p $(MARIADB_DUMPS_DIR)
	@docker exec $(shell docker-compose ps -q postgres) pg_dumpall -U "$(POSTGRES_USER)" > $(MARIADB_DUMPS_DIR)/postgres.sql 2>/dev/null
	@make resetOwner

postgres-restore:
	@docker exec -i $(shell docker-compose ps -q postgres) psql -U "$(POSTGRES_USER)" < $(MARIADB_DUMPS_DIR)/postgres.sql 2>/dev/null

phpmd:
	@docker-compose exec -T php \
	./app/vendor/bin/phpmd \
	./app/src text cleancode,codesize,controversial,design,naming,unusedcode

test: code-sniff
	@docker-compose exec -T php ./app/vendor/bin/phpunit --colors=always --configuration ./app/
	@make resetOwner

resetOwner:
	@$(shell chown -Rf $(SUDO_USER):$(shell id -g -n $(SUDO_USER)) $(MARIADB_DUMPS_DIR) "$(shell pwd)/etc/ssl" "$(shell pwd)/web/app" 2> /dev/null)

.PHONY: clean test code-sniff init