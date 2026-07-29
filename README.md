# Docker Nginx PHP MariaDB MySQL PostgreSQL

Docker stack running **Nginx** (reverse proxy + web server), **PHP-FPM**, **Composer**, and your choice of database: **MariaDB**, **MySQL**, or **PostgreSQL**.

## Overview

1. [Install prerequisites](#install-prerequisites)

    Before installing project make sure the following prerequisites have been met.

2. [Clone the project](#clone-the-project)

    We’ll download the code from its repository on GitHub.

3. [Configure Nginx With SSL Certificates](#configure-nginx-with-ssl-certificates) [`Optional`]

    We'll generate and configure SSL certificate for nginx before running server.

4. [Configure Xdebug](#configure-xdebug) [`Optional`]

    We'll configure Xdebug for IDE (PHPStorm or Netbeans).

5. [Run the application](#run-the-application)

    By this point we’ll have all the project pieces in place.

6. [Use Makefile](#use-makefile) [`Optional`]

    When developing, you can use `Makefile` for doing recurrent operations.

7. [Use Docker Commands](#use-docker-commands)

    When running, you can use docker commands for doing recurrent operations.

___

## Install prerequisites

To run the docker commands without using **sudo** you must add the **docker** group to **your-user**:

```sh
sudo usermod -aG docker your-user
```

For now, this project has been mainly created for Unix `(Linux/MacOS)`. Perhaps it could work on Windows.

All requisites should be available for your distribution. The most important are :

* [Git](https://git-scm.com/downloads)
* [Docker](https://docs.docker.com/engine/installation/)
* [Docker Compose](https://docs.docker.com/compose/install/)

Check if `docker-compose` is already installed by entering the following command:

```sh
which docker-compose
```

Check Docker Compose compatibility :

* [Compose file version 3 reference](https://docs.docker.com/compose/compose-file/)

The following is optional but makes life more enjoyable :

```sh
which make
```

On Ubuntu and Debian these are available in the meta-package build-essential. On other distributions, you may need to install the GNU C++ compiler separately.

```sh
sudo apt install build-essential
```

### Images to use

* [Nginx](https://hub.docker.com/_/nginx/)
* [PHP-FPM](https://hub.docker.com/r/archieplaylist/php-fpm/)
* [Composer](https://hub.docker.com/_/composer/)
* [MariaDB](https://hub.docker.com/_/mariadb/)
* [MySQL](https://hub.docker.com/_/mysql/)
* [PostgreSQL](https://hub.docker.com/_/postgres/)
* [Generate Certificate](https://hub.docker.com/r/jacoelho/generate-certificate/)

You should be careful when installing third party web servers such as MariaDB, MySQL, or Nginx.

**Note:** MariaDB and MySQL both use port `3306`. Only activate **one** database profile at a time.

This project uses the following ports :

| Server       | Port |
|--------------|------|
| Nginx (proxy)| 80   |
| Nginx SSL    | 443  |
| MariaDB      | 3306 |
| MySQL        | 3306 |
| PostgreSQL   | 5432 |

___

## Clone the project

To install [Git](http://git-scm.com/book/en/v2/Getting-Started-Installing-Git), download it and install following the instructions :

```sh
git clone https://github.com/nanoninja/docker-nginx-php-mysql.git
```

Go to the project directory :

```sh
cd docker-nginx-php-mysql
```

### Project tree

```sh
.
├── .env
├── Makefile
├── README.md
├── data
│   └── db
│       ├── dumps
│       ├── mariadb
│       ├── mysql
│       └── postgres
├── doc
├── docker-compose.yml
├── etc
│   ├── nginx
│   │   ├── default.conf
│   │   ├── default.template.conf
│   │   └── proxy.conf
│   ├── php
│   │   └── php.ini
│   └── ssl
└── web
    ├── app
    │   ├── composer.json.dist
    │   ├── phpunit.xml.dist
    │   ├── src
    │   │   └── Foo.php
    │   └── test
    │       ├── FooTest.php
    │       └── bootstrap.php
    └── public
        └── index.php
```

___

## Build & Update Docker Images

This project uses a custom **PHP-FPM** image built from the local `Dockerfile`, plus several pre-built images pulled from Docker Hub.

### PHP-FPM Image

The `Dockerfile` builds a PHP 8.5-FPM image with the following extensions:

- **Database**: mysqli, pdo_mysql, pdo_pgsql, pgsql
- **Caching**: memcached, redis
- **Image processing**: gd, imagick
- **Other**: xdebug, mongodb, bcmath, bz2, calendar, exif, gettext, soap, xsl, sockets, zip, intl, ldap

#### Build the PHP-FPM image

```sh
make php-build
```

#### Force rebuild (no cache)

```sh
make php-rebuild
```

### Update all Docker images

Pull the latest versions of all pre-built images (nginx, composer, mariadb, mysql, postgres, etc.):

```sh
make docker-pull
```

### Update everything (pull + rebuild PHP)

```sh
make docker-update
```

### Verify installed PHP extensions

```sh
docker exec php php -m
```

___

## Configure Nginx With SSL Certificates

You can change the host name by editing the `.env` file.

If you modify the host name, do not forget to add it to the `/etc/hosts` file.

1. Generate SSL certificates using the Makefile:

    ```sh
    make gen-certs
    ```

2. Configure Nginx

    There are two Nginx instances — a **reverse proxy** (`etc/nginx/proxy.conf`) and a **web server** (`etc/nginx/default.conf`).

    * Do not modify `etc/nginx/default.conf` — it is overwritten by `etc/nginx/default.template.conf`.
    * For SSL on the reverse proxy, edit `etc/nginx/proxy.conf` and uncomment the SSL server section:

    ```sh
    # server {
    #     listen 443 ssl default_server;
    #     listen [::]:443 ssl default_server;
    #     server_name ${NGINX_HOST};
    #
    #     ssl_certificate /etc/ssl/server.pem;
    #     ssl_certificate_key /etc/ssl/server.key;
    #     ...
    # }
    ```

    * For SSL on the web server, edit `etc/nginx/default.template.conf` and uncomment the SSL server section.

___

## Configure Xdebug

If you use another IDE than [PHPStorm](https://www.jetbrains.com/phpstorm/) or [Netbeans](https://netbeans.org/), go to the [remote debugging](https://xdebug.org/docs/remote) section of Xdebug documentation.

For a better integration of Docker to PHPStorm, use the [documentation](https://github.com/nanoninja/docker-nginx-php-mysql/blob/master/doc/phpstorm-macosx.md).

1. Get your own local IP address :

    ```sh
    sudo ifconfig
    ```

2. Edit php file `etc/php/php.ini` and comment or uncomment the configuration as needed.

3. Set the `remote_host` parameter with your IP :

    ```sh
    xdebug.remote_host=192.168.0.1 # your IP
    ```

___

## Run the application

1. Copying the composer configuration file:

    ```sh
    cp web/app/composer.json.dist web/app/composer.json
    ```

2. Choose a database and start the application:

    * **MariaDB** (port 3306):

      ```sh
      docker compose --profile mariadb up -d
      ```

    * **MySQL** (port 3306):

      ```sh
      docker compose --profile mysql up -d
      ```

    * **PostgreSQL** (port 5432):

      ```sh
      docker compose --profile pg up -d
      ```

    > **Note:** MariaDB and MySQL both map to port 3306. Do not activate both profiles at the same time.

    **Please wait this might take a several minutes...**

    ```sh
    docker compose logs -f # Follow log output
    ```

3. Open your favorite browser :

    * [http://localhost](http://localhost/)
    * [https://localhost](https://localhost/) ([HTTPS](#configure-nginx-with-ssl-certificates) not configured by default)

4. Stop and clear services

    ```sh
    docker compose --profile mariadb --profile mysql --profile pg down -v
    ```

___

## Use Makefile

When developing, you can use [Makefile](https://en.wikipedia.org/wiki/Make_(software)) for doing the following operations :

| Name              | Description                                  |
|-------------------|----------------------------------------------|
| apidoc            | Generate documentation of API                |
| clean             | Clean directories for reset                  |
| code-sniff        | Check the API with PHP Code Sniffer (`PSR2`) |
| composer-up       | Update PHP dependencies with composer        |
| docker-start      | Create and start containers                  |
| docker-stop       | Stop and clear all services                  |
| gen-certs         | Generate SSL certificates for `nginx`        |
| logs              | Follow log output                            |
| mariadb-dump      | Create backup of all MariaDB databases       |
| mariadb-restore   | Restore backup of all MariaDB databases      |
| mysql-dump        | Create backup of all MySQL databases         |
| mysql-restore     | Restore backup of all MySQL databases        |
| postgres-dump     | Create backup of all PostgreSQL databases    |
| postgres-restore  | Restore backup of all PostgreSQL databases   |
| phpmd             | Analyse the API with PHP Mess Detector       |
| test              | Test application with phpunit                |

### Examples

Start the application :

```sh
make docker-start
```

Show help :

```sh
make help
```

___

## Use Docker commands

### Installing package with composer

```sh
docker run --rm -v $(pwd)/web/app:/app composer require symfony/yaml
```

### Updating PHP dependencies with composer

```sh
docker run --rm -v $(pwd)/web/app:/app composer update
```

### Generating PHP API documentation

```sh
docker run --rm -v $(pwd):/data phpdoc/phpdoc -i=vendor/ -d /data/web/app/src -t /data/web/app/doc
```

### Testing PHP application with PHPUnit

```sh
docker compose exec -T php ./app/vendor/bin/phpunit --colors=always --configuration ./app
```

### Fixing standard code with [PSR2](http://www.php-fig.org/psr/psr-2/)

```sh
docker compose exec -T php ./app/vendor/bin/phpcbf -v --standard=PSR2 ./app/src
```

### Checking the standard code with [PSR2](http://www.php-fig.org/psr/psr-2/)

```sh
docker compose exec -T php ./app/vendor/bin/phpcs -v --standard=PSR2 ./app/src
```

### Analyzing source code with [PHP Mess Detector](https://phpmd.org/)

```sh
docker compose exec -T php ./app/vendor/bin/phpmd ./app/src text cleancode,codesize,controversial,design,naming,unusedcode
```

### Checking installed PHP extensions

```sh
docker compose exec php php -m
```

### Handling databases

#### MariaDB shell access

```sh
docker exec -it mariadb mariadb -u"$MARIADB_ROOT_USER" -p"$MARIADB_ROOT_PASSWORD"
```

#### Creating a backup of all MariaDB databases

```sh
make mariadb-dump
```

#### Restoring a backup of all MariaDB databases

```sh
make mariadb-restore
```

#### MySQL shell access

```sh
docker exec -it mysql mysql -u"root" -p"$MYSQL_ROOT_PASSWORD"
```

#### Creating a backup of all MySQL databases

```sh
make mysql-dump
```

#### Restoring a backup of all MySQL databases

```sh
make mysql-restore
```

#### PostgreSQL shell access

```sh
docker exec -it postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
```

#### Creating a backup of all PostgreSQL databases

```sh
make postgres-dump
```

#### Restoring a backup of all PostgreSQL databases

```sh
make postgres-restore
```

___

## Production Deployment

This project includes a production-ready override file (`docker-compose.prod.yml`) that hardens the stack with security headers, health checks, resource limits, OPcache, and proper TLS.

### Quick start

1. **Prepare environment**

    ```sh
    cp .env.prod.example .env.prod
    ```

    Edit `.env.prod` with your domain and strong passwords. **Never commit `.env.prod`** — it's gitignored.

2. **Set up SSL certificates**

    ```sh
    make gen-certs
    ```

    For production, replace the self-signed certs with real ones from [Let's Encrypt](https://letsencrypt.org/) placed in `etc/ssl/`.

3. **Start in production mode**

    ```sh
    # With MariaDB
    make docker-start-prod

    # Or with MySQL
    docker compose -f docker-compose.yml -f docker-compose.prod.yml --profile mysql up -d

    # Or with PostgreSQL
    docker compose -f docker-compose.yml -f docker-compose.prod.yml --profile pg up -d
    ```

4. **Check health**

    ```sh
    make health
    ```

    All services should show `healthy` within 30-60 seconds.

### What changes in production mode

| Aspect | Dev | Production |
| --- | --- | --- |
| **PHP config** | `php.ini` (Xdebug enabled) | `php.prod.ini` (OPcache, no Xdebug, security hardened) |
| **Nginx proxy** | `proxy.conf` (HTTP only) | `proxy.prod.conf` (HTTPS, security headers, gzip, rate limiting) |
| **Nginx web** | `default.template.conf` | `default.template.prod.conf` (security headers, gzip, deny hidden files) |
| **Health checks** | None | All services monitored |
| **Resource limits** | None | Memory/CPU per service |
| **SSL** | Commented out | Enabled with modern TLS 1.2/1.3 |
| **HTTP→HTTPS** | No redirect | Automatic redirect |

### Production commands

```sh
make docker-start-prod   # Start with production override
make docker-stop-prod    # Stop and remove containers
make logs-prod           # Follow production logs
make health              # Show container health status
make backup-auto         # Create timestamped database backup
```

### Security checklist

* [ ] Replace `.env.prod` passwords with strong, unique values
* [ ] Replace self-signed SSL certs with Let's Encrypt or a trusted CA
* [ ] Verify CSP in `proxy.prod.conf` matches your application needs
* [ ] Disable any unused PHP extensions in `php.prod.ini`
* [ ] Set up automated backups (add `make backup-auto` to your crontab)
* [ ] Use a reverse proxy firewall (e.g. Cloudflare, AWS WAF) in front of the server
* [ ] Regularly update base images: `docker compose pull`
