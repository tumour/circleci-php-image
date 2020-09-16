FROM circleci/php:7.2-node-browsers

USER root

RUN apt-get update

RUN docker-php-ext-install zip pdo_mysql

RUN apt-get install -y \
	software-properties-common \
	vim \
	python-pip

# Install ansible
RUN pip install ansible

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

# Install php deployer
RUN curl -LO https://deployer.org/deployer.phar && \
    mv deployer.phar /usr/local/bin/dep && \
    chmod +x /usr/local/bin/dep

# Install MySQL client
RUN apt-get install mysql-client
