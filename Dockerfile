FROM php:7.4-fpm-alpine3.13

# Локаль 
ENV LANG "C.UTF-8" 
ENV LANGUAGE "C.UTF-8" 
ENV LC_ALL "C.UTF-8"

RUN apk update && apk add --no-cache \
	git \
    unzip \
    bash \
    zip \
    curl \
    rsync \
    openssh-client \
    libzip-dev \
    libxml2-dev \
    libpng-dev \
    freetype-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libjpeg \
    jpeg-dev \
    ldb-dev \
    libldap \
    openldap-dev

# install dockerize
RUN DOCKERIZE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/dockerize-latest.tar.gz" \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/dockerize-linux-amd64.tar.gz $DOCKERIZE_URL \
  && tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64.tar.gz \
  && rm -rf /tmp/dockerize-linux-amd64.tar.gz \
  && dockerize --version

# Composer
RUN curl -sL https://getcomposer.org/installer | php -- --install-dir /usr/bin --filename composer --version=2.0.14

RUN docker-php-ext-install pdo_mysql zip soap ldap exif

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

CMD ["/bin/sh"]
