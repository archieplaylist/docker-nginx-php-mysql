# Docker Nginx PHP MariaDB PostgreSQL

Docker stack running **Nginx** (reverse proxy + web server), **PHP-FPM**, **Composer**, **MariaDB**, and optional **PostgreSQL**.

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
* [PostgreSQL](https://hub.docker.com/_/postgres/)
* [Generate Certificate](https://hub.docker.com/r/jacoelho/generate-certificate/)

You should be careful when installing third party web servers such as MariaDB or Nginx.

This project uses the following ports :

| Server       | Port |
|--------------|------|
| Nginx (proxy)| 80   |
| Nginx SSL    | 443  |
| MariaDB      | 3306 |
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

2. Start the application :

    ```sh
    docker compose up -d
    ```

    **Please wait this might take a several minutes...**

    ```sh
    docker compose logs -f # Follow log output
    ```

3. Open your favorite browser :

    * [http://localhost](http://localhost/)
    * [https://localhost](https://localhost/) ([HTTPS](#configure-nginx-with-ssl-certificates) not configured by default)

4. To also start PostgreSQL (optional):

    ```sh
    docker compose --profile pg up -d
    ```

5. Stop and clear services

    ```sh
    docker compose down -v
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
