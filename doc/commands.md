# Docker Nginx PHP MySQL - Command Line Reference

This document provides a comprehensive reference of all available commands in the Docker Nginx PHP MySQL environment. These commands can be executed using the `make` utility or directly with Docker and Docker Compose commands.

## Environment Management Commands

These commands help you manage your development and production environments.

### `init`

Initializes the project by setting up the environment and installing dependencies.

```bash
# Using make
make init

# Manual alternative
cp .env.dev .env
cp web/app/composer.json.dist web/app/composer.json
docker compose up -d
docker compose exec php composer install -d /var/www/html/app
```

### `dev`

Configures the environment for development.

```bash
# Using make
make dev

# Manual alternative
cp .env.dev .env
docker compose restart
```

### `prod`

Configures the environment for production.

```bash
# Using make
make prod

# Manual alternative
cp .env.prod .env
docker compose restart
```

### `start`

Starts all services defined in the Docker Compose file.

```bash
# Using make
make start

# Manual alternative
docker compose up -d
```

### `stop`

Stops all services and removes containers.

```bash
# Using make
make stop

# Manual alternative
docker compose down
```

### `restart`

Restarts all services.

```bash
# Using make
make restart

# Manual alternative
docker compose down
docker compose up -d
```

### `status`

Displays the status of all containers.

```bash
# Using make
make status

# Manual alternative
docker compose ps
```

### `logs`

Displays and follows log output from all containers.

```bash
# Using make
make logs

# Manual alternative
docker compose logs -f
```

## PHP Development Commands

These commands help with PHP dependency management and code quality.

### `composer-install`

Installs PHP dependencies using Composer.

```bash
# Using make
make composer-install

# Manual alternative
docker compose exec php composer install -d /var/www/html/app
```

### `composer-update`

Updates PHP dependencies to their latest versions.

```bash
# Using make
make composer-update

# Manual alternative
docker compose exec php composer update -d /var/www/html/app
```

### `composer-autoload`

Updates the Composer autoloader.

```bash
# Using make
make composer-autoload

# Manual alternative
docker compose exec php composer dump-autoload -d /var/www/html/app
```

### `test`

Runs PHPUnit tests.

```bash
# Using make
make test

# Manual alternative
docker compose exec php ./app/vendor/bin/phpunit --colors=always --configuration ./app/
```

### `code-sniff`

Checks the code against PSR2 coding standards.

```bash
# Using make
make code-sniff

# Manual alternative
docker compose exec php ./app/vendor/bin/phpcs -v --standard=PSR2 app/src
```

### `phpmd`

Analyzes code with PHP Mess Detector.

```bash
# Using make
make phpmd

# Manual alternative
docker compose exec php ./app/vendor/bin/phpmd ./app/src text cleancode,codesize,controversial,design,naming,unusedcode
```

### `apidoc`

Generates API documentation.

```bash
# Using make
make apidoc

# Manual alternative
docker run --rm -v $(pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/app/src -t /data/web/app/doc
```

## Database Commands

These commands help manage the MySQL database.

### `db-dump`

Creates a backup of all databases.

```bash
# Using make
make db-dump

# Manual alternative
mkdir -p data/db/dumps
docker exec $(docker compose ps -q mysqldb) mysqldump --all-databases -u"root" -p"root" > data/db/dumps/db.sql
```

### `db-restore`

Restores a backup of all databases.

```bash
# Using make
make db-restore

# Manual alternative
docker exec -i $(docker compose ps -q mysqldb) mysql -u"root" -p"root" < data/db/dumps/db.sql
```

### `db-connect`

Opens a MySQL shell.

```bash
# Using make
make db-connect

# Manual alternative
docker exec -it $(docker compose ps -q mysqldb) mysql -u"root" -p"root"
```

### `db-volume-create`

Creates a named volume for MySQL data.

```bash
# Using make
make db-volume-create

# Manual alternative
docker volume create docker_nginx_php_mysql_mysql_data
```

### `db-volume-remove`

Removes the MySQL data volume.

```bash
# Using make
make db-volume-remove

# Manual alternative
docker volume rm docker_nginx_php_mysql_mysql_data
```

## Framework Installation Commands

These commands install popular PHP frameworks.

### `install-symfony`

Installs the Symfony framework.

```bash
# Using make
make install-symfony

# Manual alternative
docker compose exec php composer create-project symfony/skeleton symfony-app
```

### `install-laravel`

Installs the Laravel framework.

```bash
# Using make
make install-laravel

# Manual alternative
docker compose exec php composer create-project laravel/laravel laravel-app
```

## Utility Commands

These commands provide various utilities.

### `clean`

Cleans up directories for a reset.

```bash
# Using make
make clean

# Manual alternative
rm -rf web/app/vendor
rm -rf web/app/composer.lock
rm -rf web/app/doc
rm -rf web/app/report
rm -rf etc/ssl/*
rm -rf .phpdoc
```

### `clean-all`

Cleans all data including Docker volumes.

```bash
# Using make
make clean-all

# Manual alternative
rm -rf web/app/vendor
rm -rf web/app/composer.lock
rm -rf web/app/doc
rm -rf web/app/report
rm -rf etc/ssl/*
rm -rf .phpdoc
docker volume rm docker_nginx_php_mysql_mysql_data
```

### `gen-certs`

Generates SSL certificates.

```bash
# Using make
make gen-certs

# Manual alternative
docker run --rm -v $(pwd)/etc/ssl:/certificates -e "SERVER=localhost" \
  alpine:latest /bin/sh -c "apk add --no-cache openssl && \
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /certificates/server.key -out /certificates/server.crt \
  -subj '/CN=localhost'"
```

### `enable-ssl`

Enables SSL in the Nginx configuration.

```bash
# Using make
make enable-ssl

# Manual alternative
cp etc/nginx/default.template.conf etc/nginx/default.conf
# Then manually uncomment the SSL server block in the configuration file
docker compose restart
```

## Notes for Windows Users

If you're using Windows and don't have access to the `make` command, you can:

1. Install Make for Windows through [GnuWin32](http://gnuwin32.sourceforge.net/packages/make.htm)
2. Use WSL (Windows Subsystem for Linux)
3. Use the manual alternative commands listed above
4. Use Git Bash which provides a Unix-like terminal

For specific Windows issues or if you encounter any problems, please refer to the project's GitHub issue tracker.