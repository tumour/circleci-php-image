FROM php:7.3-fpm

RUN apt-get update && apt-get install -y \
	nano \
    locales

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# Composer
RUN curl -sL https://getcomposer.org/installer | php -- --install-dir /usr/bin --filename composer

# exif
RUN docker-php-ext-install exif
RUN docker-php-ext-configure exif \
            --enable-exif

# PDO
RUN docker-php-ext-install pdo_mysql

# zip
RUN apt-get install -y \
        libzip-dev \
        zip \
  && docker-php-ext-install zip

# GB
RUN apt-get update && apt-get install --assume-yes zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
&& docker-php-ext-install -j$(nproc) gd \
&& docker-php-ext-enable gd

# soap
RUN rm /etc/apt/preferences.d/no-debian-php && \
    apt-get update && apt-get install -y \
    libssl-dev \
    libxml2-dev \
    php-soap \
&& apt-get clean -y \
&& docker-php-ext-install soap \
&& docker-php-ext-enable soap

# ldap
RUN docker-php-ext-install xml
RUN \
    apt-get update && \
    apt-get install libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap
USER circleci
ENV PATH /home/circleci/.local/bin:/home/circleci/bin:${PATH}

CMD ["/bin/sh"]
