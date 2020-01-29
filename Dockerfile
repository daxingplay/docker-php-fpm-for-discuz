FROM php:7.4-fpm-alpine3.11

ENV PHP_MAX_POST_SIZE 5m
ENV PHP_ERROR_LOG stderr

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    touch "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "post_max_size = ${PHP_MAX_POST_SIZE}" > "$PHP_INI_DIR/conf.d/custom.ini" && \
    echo "error_log = ${PHP_ERROR_LOG}" > "$PHP_INI_DIR/conf.d/custom.ini" && \
    apk add -U --no-cache \
        git libmemcached-libs zlib libmemcached-dev zlib-dev cyrus-sasl-dev build-base autoconf \
        openssl-dev \
        libmcrypt-dev \
        libpng-dev \
        icu-dev \
        libpq \
        libxslt-dev \
        libffi-dev \
        freetype-dev \
        sqlite-dev \
        imap-dev \
        gd-dev \
        libzip-dev \
        libjpeg-turbo-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure zip && \
    docker-php-ext-configure imap && \
    #curl iconv session
    #docker-php-ext-install pdo_mysql pdo_sqlite mysqli mcrypt gd exif intl xsl json soap dom zip opcache && \
    docker-php-ext-install iconv imap pdo_mysql pdo_sqlite mysqli gd exif intl xsl json soap dom zip opcache && \
    pecl install redis memcached && \
    git clone https://github.com/websupport-sk/pecl-memcache /usr/src/memcache && \
    cd /usr/src/memcache && \
    phpize && \
    ./configure --with-php-config=/usr/local/bin/php-config && \
    make && \
    make install && \
    docker-php-ext-enable redis memcached memcache && \
    apk del git libmemcached-dev zlib-dev cyrus-sasl-dev build-base autoconf && \
    rm -rf /tmp/* && \
    rm -rf /usr/src/memcache && \
    docker-php-source delete

# RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
# ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
