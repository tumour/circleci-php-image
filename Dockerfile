FROM php:7.2-fpm

# переключаем Ubuntu в неинтерактивный режим, чтобы избежать лишних запросов
ENV DEBIAN_FRONTEND noninteractive

# устанавливаем локаль
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

ENV LANG ru_RU.UTF-8

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get update && apt-get install -y --no-install-recommends \
  libmcrypt-dev \
  mariadb-client \
  libmagickwand-dev \
  zip \
  unzip \
  rsync \
  git \
  librabbitmq-dev \
  libc-client-dev \
  libkrb5-dev \
  openssh-client

#install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath xml sockets

RUN pecl install redis \
  && docker-php-ext-enable redis

RUN pecl install amqp-1.11.0 \
  && docker-php-ext-enable amqp

RUN docker-php-ext-install gd

#install phalcon
RUN cd /usr/local \
  && git clone -b v3.4.2 --depth=1 "https://github.com/phalcon/cphalcon.git" \
  && cd /usr/local/cphalcon/build \
  && ./install \
  && docker-php-ext-enable phalcon \
  && rm -rf /usr/local/cphalcon

RUN cd /usr/local \
  && git clone -b v3.4.1 --depth=1 "https://github.com/phalcon/phalcon-devtools.git" \
  && ln -s /usr/local/phalcon-devtools/phalcon.php /usr/local/bin/phalcon \
  && chmod ugo+x /usr/local/bin/phalcon

#RUN useradd -G www-data,root -u 1000 -d /home/cicd cicd
RUN mkdir -p /root/cicd
#RUN chown -R 1000:1000 "/home/cicd"

WORKDIR /home/cicd/project

CMD ["/bin/sh"]
