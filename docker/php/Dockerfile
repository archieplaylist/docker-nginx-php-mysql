# docker/php/Dockerfile
ARG PHP_VERSION=8.4

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
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    mysqli \
    pdo_mysql \
    zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Cleanup
RUN apt-get remove -y g++ \
    && apt-get autoremove --purge -y \
    && apt-get autoclean -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

# Set working directory
WORKDIR /var/www/html

# Default command
CMD ["php-fpm"]