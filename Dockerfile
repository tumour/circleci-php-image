FROM php:8.1-fpm-alpine

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
	libwebp-dev \
	freetype-dev \
	libjpeg-turbo \
	libjpeg-turbo-dev \
	libjpeg \
	jpeg-dev \
	ldb-dev \
	libldap \
	openldap-dev \
	jpegoptim \
	optipng \
	pngquant \
	gifsicle \
    nodejs \
    npm \
    python3 \
    make \
    g++

# install dockerize
#RUN DOCKERIZE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/dockerize-latest.tar.gz" \
#  && curl --silent --show-error --location --fail --retry 3 --output /tmp/dockerize-linux-amd64.tar.gz $DOCKERIZE_URL \
#  && tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64.tar.gz \
#  && rm -rf /tmp/dockerize-linux-amd64.tar.gz \
#  && dockerize --version

# Composer
RUN curl -sL https://getcomposer.org/installer | php -- --install-dir /usr/bin --filename=composer

RUN docker-php-ext-install pdo_mysql zip soap ldap exif opcache

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp \
	&& docker-php-ext-install -j$(nproc) gd 

RUN printf '%s\n' 'zend_extension=opcache.so' 'opcache.enable=1' 'opcache.enable_cli=1' 'opcache.fast_shutdown=1' 'opcache.memory_consumption=128' 'opcache.interned_strings_buffer=8' 'opcache.max_accelerated_files=4000' 'opcache.revalidate_freq=60' > /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

CMD ["/bin/sh"]
