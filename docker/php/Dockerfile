# docker/php/Dockerfile
ARG PHP_VERSION

# Base PHP image with essential extensions
FROM php:${PHP_VERSION}-fpm AS php-base

LABEL maintainer="Vincent Letourneau <vincent@nanoninja.com>"
LABEL version="2.0.0"
LABEL description="PHP-FPM image for docker-nginx-php-mysql with essential extensions"

# Install essential dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    g++ \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libicu-dev \
    libssl-dev \
    libxslt-dev \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    calendar \
    exif \
    mysqli \
    opcache \
    pdo_mysql \
    xsl \
    zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Optimized PHP configuration for production
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Cleanup
RUN apt-get remove -y g++ \
    && apt-get autoremove --purge -y \
    && apt-get autoclean -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

# Set working directory
WORKDIR /var/www/html

ARG PHP_TARGET

# If building for development, add development extensions
RUN if [ "$PHP_TARGET" = "dev" ]; then \
    apt-get update && apt-get install -y \
    libbz2-dev \
    libc-client-dev \
    libcurl4-gnutls-dev \
    libedit-dev \
    libkrb5-dev \
    libldap2-dev \
    libldb-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpq-dev \
    libsqlite3-dev \
    memcached \
    wget \
    unzip \
    && docker-php-ext-install -j$(nproc) \
    bz2 \
    gettext \
    pdo_pgsql \
    pgsql \
    soap \
    sockets \
    && PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \
    # && pecl install imagick && docker-php-ext-enable imagick \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install ldap \
    && pecl install xdebug && docker-php-ext-enable xdebug \
    && pecl install memcached && docker-php-ext-enable memcached \
    && pecl install mongodb && docker-php-ext-enable mongodb \
    && pecl install redis && docker-php-ext-enable redis \
    && docker-php-source delete \
    && apt-get remove -y wget \
    && apt-get autoremove --purge -y && apt-get autoclean -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* \
    && echo 'xdebug.mode=develop,debug' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.client_host=host.docker.internal' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.start_with_request=yes' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ; \
else \
    echo "Building production image without development tools."; \
fi

# Default command
CMD ["php-fpm"]