FROM php:7.4-fpm

RUN apt-get update && apt-get install -y \
	git apt \
    locales sudo openssh-client ca-certificates tar gzip \
    unzip zip bzip2 curl wget \
    rsync

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# install dockerize
RUN DOCKERIZE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/dockerize-latest.tar.gz" \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/dockerize-linux-amd64.tar.gz $DOCKERIZE_URL \
  && tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64.tar.gz \
  && rm -rf /tmp/dockerize-linux-amd64.tar.gz \
  && dockerize --version

##
RUN groupadd --gid 3434 circleci \
&& useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
&& echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
&& echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

# Composer
RUN curl -sL https://getcomposer.org/installer | php -- --install-dir /usr/bin --filename composer --version=2.0.14

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
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
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

ENV PATH /home/circleci/.local/bin:/home/circleci/bin:${PATH}

CMD ["/bin/sh"]
