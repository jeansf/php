FROM php:7.4-apache-buster
LABEL maintainer="Jean Soares Fernandes <3454862+jeansf@users.noreply.github.com>"

# Setup timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo "date.timezone=$TZ" >> /usr/local/etc/php/conf.d/default.ini
RUN sed -i 's/#AddDefaultCharset UTF-8/AddDefaultCharset UTF-8/g'  /etc/apache2/conf-enabled/charset.conf

# Update sources
RUN apt-get update -y && apt-get upgrade -y

# Enable "mod_rewrite" – http://httpd.apache.org/docs/current/mod/mod_rewrite.html
RUN a2enmod rewrite

# Enable "mod_headers" – http://httpd.apache.org/docs/current/mod/mod_headers.html
RUN a2enmod headers

# Enable "mod_expires" – http://httpd.apache.org/docs/current/mod/mod_expires.html
RUN a2enmod expires

# Remove default config apache2
RUN a2dissite 000-default

# Install "Git" – https://git-scm.com/
RUN apt-get install -y git

# Install "Composer" – https://getcomposer.org/
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Midnight Commander, Vim, Nano
RUN apt-get install -y mc vim nano

# Install "ImageMagick" executable – https://www.imagemagick.org/script/index.php
RUN apt-get install -y imagemagick

# Install PHP "curl" extension – http://php.net/manual/en/book.curl.php
RUN apt-get install -y zlib1g-dev libicu-dev g++
RUN apt-get install -y libcurl4-openssl-dev
RUN docker-php-ext-install curl

# Install PHP "intl" extension – http://php.net/manual/en/book.intl.php
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# Install PHP "xsl" extension – http://php.net/manual/en/book.xsl.php
RUN apt-get install -y libxslt-dev
RUN docker-php-ext-install xsl

# Install PHP "exif" extension – http://php.net/manual/en/book.exif.php
RUN apt-get install -y libexif-dev
RUN docker-php-ext-install exif

# Install PHP "mysqli" extension – http://php.net/manual/pl/book.mysqli.php
RUN docker-php-ext-install mysqli

# Install PHP "pdo" extension with "mysql", "pgsql", "sqlite" drivers – http://php.net/manual/pl/book.pdo.php
RUN apt-get install -y libpq-dev libsqlite3-dev
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pdo_mysql pgsql pdo_pgsql pdo_sqlite

# Install PHP "opcache" extension – http://php.net/manual/en/book.opcache.php
RUN docker-php-ext-install opcache

# Install PHP "memcached" extension – http://php.net/manual/en/book.memcached.php
RUN apt-get install -y libmemcached-dev \
&& pecl install memcached \
&& docker-php-ext-enable memcached

# Install PHP "gd" extension
RUN apt-get install -y libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libfreetype6-dev
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-xpm
RUN docker-php-ext-install gd

# Install PHP "zip" extension
RUN apt-get install -y libzip-dev
RUN docker-php-ext-install zip

# Install configure PHP curl ssl
RUN apt-get install -y ca-certificates
RUN curl --remote-name --time-cond cacert.pem https://curl.haxx.se/ca/cacert.pem && mv cacert.pem /etc/ssl/certs/cacert.pem && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/^.*curl.cainfo.*$/curl.cainfo = \"\/etc\/ssl\/certs\/cacert.pem\"/' /usr/local/etc/php/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 256M/" /usr/local/etc/php/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 256M/" /usr/local/etc/php/php.ini && \
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /usr/local/etc/php/php.ini

# Install configure PHP socket
#RUN apt-get install -y libssh-dev && \
RUN docker-php-ext-install sockets

# Install configure PHP amqp
RUN apt-get install -y librabbitmq-dev
RUN pecl install amqp && docker-php-ext-enable amqp

# Install configure PHP json, iconv, ctype
RUN docker-php-ext-install json
RUN docker-php-ext-install iconv
RUN docker-php-ext-install ctype

# Install configure PHP calendar
RUN docker-php-ext-install ctype

# Cleanup the image
RUN rm -rf /var/lib/apt/lists/* /tmp/*

# Create default with wildcard servername
COPY configs/symfony.conf /etc/apache2/sites-available/symfony.conf
RUN a2ensite symfony

# Remove warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
