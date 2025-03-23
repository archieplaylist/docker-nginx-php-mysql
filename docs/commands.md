# Docker Nginx PHP MySQL - Command Line Reference

This document provides a comprehensive reference of all available commands in the Docker Nginx PHP MySQL environment. These commands can be executed using the `make` utility or directly with Docker and Docker Compose commands.

## Environment Variables for Manual Commands

When running the commands manually without Make, you can use these variables for consistency:

```bash
# Core directories and settings
WEB_ROOT="./web"
APP_DIR="app"  # Change this to your application directory (e.g., symfony-app, laravel-app)
APP_ROOT="${WEB_ROOT}/${APP_DIR}"
MYSQL_DUMPS_DIR="data/db/dumps"
COMPOSE_PROJECT_NAME="docker_nginx_php_mysql"  # Change to match your .env configuration

# Container information
PHP_CONTAINER="php"
MYSQL_CONTAINER=$(docker compose ps -q mysqldb 2>/dev/null)
```

## Environment Management Commands

These commands help you manage your development and production environments.

### `init`

Initializes the project by setting up the environment and installing dependencies.

```bash
# Using make
make init

# Manual alternative
cp .env.dev .env
mkdir -p ${APP_ROOT}
cp ${WEB_ROOT}/composer.json.dist ${APP_ROOT}/composer.json 2>/dev/null || echo "{}" > ${APP_ROOT}/composer.json
docker compose up -d
docker compose exec -T ${PHP_CONTAINER} composer install -d /var/www/html/${APP_DIR}
```

### `dev`

Configures the environment for development.

```bash
# Using make
make dev

# Manual alternative
cp .env.dev .env
docker compose down
docker compose --profile dev up -d
```

### `prod`

Configures the environment for production.

```bash
# Using make
make prod

# Manual alternative
cp .env.prod .env
docker compose down
docker compose up -d
```

### `start`

Starts all services defined in the Docker Compose file.

```bash
# Using make
make start

# Manual alternative
# For development environment (with PHPMyAdmin)
docker compose --profile dev up -d
# For production environment (without PHPMyAdmin)
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
docker compose exec -T ${PHP_CONTAINER} composer install -d /var/www/html/${APP_DIR}
```

### `composer-update`

Updates PHP dependencies to their latest versions.

```bash
# Using make
make composer-update

# Manual alternative
docker compose exec -T ${PHP_CONTAINER} composer update -d /var/www/html/${APP_DIR}
```

### `composer-autoload`

Updates the Composer autoloader.

```bash
# Using make
make composer-autoload

# Manual alternative
docker compose exec -T ${PHP_CONTAINER} composer dump-autoload -d /var/www/html/${APP_DIR}
```

### `composer-script`

Runs a composer script with optional arguments.

```bash
# Using make with arguments
make composer-script SCRIPT=test ARGS="--filter=TestClass"

# Manual alternative
docker compose exec -T ${PHP_CONTAINER} composer run-script test --filter=TestClass -d /var/www/html/${APP_DIR}
```

### `test`

Runs PHPUnit tests.

```bash
# Using make
make test

# Manual alternative
docker compose exec -T ${PHP_CONTAINER} ./${APP_DIR}/vendor/bin/phpunit --colors=always --configuration ./${APP_DIR}/
```

### `code-sniff`

Checks the code against PSR2 coding standards.

```bash
# Using make
make code-sniff

# Manual alternative
docker compose exec -T ${PHP_CONTAINER} ./${APP_DIR}/vendor/bin/phpcs -v --standard=PSR2 ${APP_DIR}/src
```

### `phpmd`

Analyzes code with PHP Mess Detector.

```bash
# Using make
make phpmd

# Manual alternative
docker compose exec -T ${PHP_CONTAINER} ./${APP_DIR}/vendor/bin/phpmd ./${APP_DIR}/src text cleancode,codesize,controversial,design,naming,unusedcode
```

## API Documentation Commands

These commands help generate and serve API documentation.

### `apidocs-generate`

Generates API documentation using phpDocumentor.

```bash
# Using make
make apidocs-generate

# Manual alternative
mkdir -p ./docs/api/html
docker run --rm -v $(pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/${APP_DIR}/src -t /data/docs/api/html
chown -R $(id -u):$(id -g) ./docs/api
```

### `apidocs-serve`

Starts a web server to view the generated API documentation.

```bash
# Using make
make apidocs-serve

# Manual alternative
docker compose --profile dev up -d apidocs
echo "API documentation available at http://localhost:8081"
```

### `apidocs`

Generates and serves API documentation in one command.

```bash
# Using make
make apidocs

# Manual alternative
mkdir -p ./docs/api/html
docker run --rm -v $(pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/${APP_DIR}/src -t /data/docs/api/html
chown -R $(id -u):$(id -g) ./docs/api
docker compose --profile dev up -d apidocs
echo "API documentation available at http://localhost:8081"
```

## Container Access Commands

These commands provide direct access to container shells.

### `php-connect`

Opens a shell in the PHP container.

```bash
# Using make
make php-connect

# Manual alternative
docker compose exec -it ${PHP_CONTAINER} bash
```

### `db-connect`

Opens a MySQL shell.

```bash
# Using make
make db-connect

# Manual alternative
docker exec -it $(docker compose ps -q mysqldb) mysql -uroot -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f2)
```

## Database Commands

These commands help manage the MySQL database.

### `db-dump`

Creates a backup of all databases.

```bash
# Using make
make db-dump

# Manual alternative
mkdir -p ${MYSQL_DUMPS_DIR}
MYSQL_ROOT_PASSWORD=$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f2)
docker exec $(docker compose ps -q mysqldb) mysqldump --all-databases -u"root" -p"${MYSQL_ROOT_PASSWORD}" > ${MYSQL_DUMPS_DIR}/db.sql
chown -R $(id -u):$(id -g) ${MYSQL_DUMPS_DIR}
```

### `db-restore`

Restores a backup of all databases.

```bash
# Using make
make db-restore

# Manual alternative
if [ -f "${MYSQL_DUMPS_DIR}/db.sql" ]; then
  MYSQL_ROOT_PASSWORD=$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f2)
  docker exec -i $(docker compose ps -q mysqldb) mysql -u"root" -p"${MYSQL_ROOT_PASSWORD}" < ${MYSQL_DUMPS_DIR}/db.sql
else
  echo "Backup file not found at ${MYSQL_DUMPS_DIR}/db.sql"
fi
```

## Framework Installation Commands

These commands install popular PHP frameworks.

### `install-symfony`

Installs the Symfony framework.

```bash
# Using make
make install-symfony

# Manual alternative
if [ -d "${WEB_ROOT}/symfony-app" ]; then
  echo "Directory 'symfony-app' already exists!"
  echo "Please remove or rename the existing directory before installing Symfony."
  exit 1
fi
docker compose exec -T ${PHP_CONTAINER} bash -c "cd /var/www/html && composer create-project symfony/skeleton symfony-app"
echo "Symfony installed in ./web/symfony-app!"
echo "To configure your environment for Symfony, update these variables in .env:"
echo "APP_WORKSPACE=symfony"
echo "APP_DIR=symfony-app"
echo "Then restart the containers with: docker compose restart"
```

### `install-laravel`

Installs the Laravel framework.

```bash
# Using make
make install-laravel

# Manual alternative
if [ -d "${WEB_ROOT}/laravel-app" ]; then
  echo "Directory 'laravel-app' already exists!"
  echo "Please remove or rename the existing directory before installing Laravel."
  exit 1
fi
docker compose exec -T ${PHP_CONTAINER} bash -c "cd /var/www/html && composer create-project laravel/laravel laravel-app"
echo "Laravel installed in ./web/laravel-app!"
echo "To configure your environment for Laravel, update these variables in .env:"
echo "APP_WORKSPACE=laravel"
echo "APP_DIR=laravel-app"
echo "Then restart the containers with: docker compose restart"
```

## Utility Commands

These commands provide various utilities.

### `env-clean`

Cleans environment resources.

```bash
# Using make
make env-clean

# Manual alternative
docker container prune -f --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}"
docker network prune -f --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}"
rm -rf .phpdoc
rm -rf etc/ssl/*
```

### `env-reset`

Resets the environment completely, including volumes.

```bash
# Using make
make env-reset

# Manual alternative
docker compose down
docker container prune -f --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}"
docker network prune -f --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}"
docker volume rm $(docker volume ls -q -f name=${COMPOSE_PROJECT_NAME}) 2>/dev/null || true
rm -rf .phpdoc
rm -rf etc/ssl/*
rm -rf ${MYSQL_DUMPS_DIR}/*
```

### `gen-certs`

Generates SSL certificates.

```bash
# Using make
make gen-certs

# Manual alternative
docker build -t ssl-generator docker/ssl
NGINX_HOST=$(grep NGINX_HOST .env | cut -d '=' -f2)
NGINX_SSL_COUNTRY=$(grep NGINX_SSL_COUNTRY .env | cut -d '=' -f2)
NGINX_SSL_STATE=$(grep NGINX_SSL_STATE .env | cut -d '=' -f2)
NGINX_SSL_LOCALITY=$(grep NGINX_SSL_LOCALITY .env | cut -d '=' -f2)
NGINX_SSL_ORGANIZATION=$(grep NGINX_SSL_ORGANIZATION .env | cut -d '=' -f2)
NGINX_SSL_UNIT=$(grep NGINX_SSL_UNIT .env | cut -d '=' -f2)
NGINX_SSL_EMAIL=$(grep NGINX_SSL_EMAIL .env | cut -d '=' -f2)
NGINX_SSL_DAYS=$(grep NGINX_SSL_DAYS .env | cut -d '=' -f2)
NGINX_SSL_KEY_SIZE=$(grep NGINX_SSL_KEY_SIZE .env | cut -d '=' -f2)

docker run --rm -v $(pwd)/etc/ssl:/certificates \
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
chown -R $(id -u):$(id -g) $(pwd)/etc/ssl
```

### `enable-ssl`

Enables SSL in the Nginx configuration.

```bash
# Using make
make enable-ssl

# Manual alternative
docker run --rm -v $(pwd)/etc/nginx:/etc/nginx alpine:latest \
  sh -c 'apk add --no-cache sed && sed -i "/^# server {/,/^# }/ s/^# //" /etc/nginx/default.template.conf && sed -i "/^#[[:space:]]*$/s/^#//" /etc/nginx/default.template.conf'
docker compose restart
NGINX_HOST=$(grep NGINX_HOST .env | cut -d '=' -f2)
echo "SSL has been enabled. Access your site at https://${NGINX_HOST}:3000"
```

### `xdebug-check`

Checks Xdebug configuration.

```bash
# Using make
make xdebug-check

# Manual alternative
docker compose exec -T ${PHP_CONTAINER} php -v
docker compose exec -T ${PHP_CONTAINER} php -i | grep -i xdebug
```

### `xdebug-restart`

Restarts the PHP container with Xdebug.

```bash
# Using make
make xdebug-restart

# Manual alternative
docker compose restart php
echo "PHP container restarted!"
docker compose exec -T ${PHP_CONTAINER} php -v | grep -i xdebug
```

## Notes for Windows Users

If you're using Windows and don't have access to the `make` command, you can:

1. Install Make for Windows through [GnuWin32](http://gnuwin32.sourceforge.net/packages/make.htm)
2. Use WSL (Windows Subsystem for Linux)
3. Use the manual alternative commands listed above
4. Use Git Bash which provides a Unix-like terminal

For Windows users using Command Prompt or PowerShell, you may need to adapt some commands, particularly those using environment variables and paths.

For specific Windows issues or if you encounter any problems, please refer to the project's GitHub issue tracker.
