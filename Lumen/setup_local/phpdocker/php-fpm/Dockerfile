FROM php:8.0-fpm
WORKDIR "/application"

RUN apt-get update --fix-missing
RUN apt-get install -y curl openssl unzip zip
RUN apt-get install -y build-essential libssl-dev zlib1g-dev libpng-dev libjpeg-dev libfreetype6-dev

RUN apt-get -y install gcc make autoconf libc-dev pkg-config
RUN apt-get -y install libmcrypt-dev

# RUN docker-php-ext-install php-mysql
RUN pecl config-set php_ini "${PHP_INI_DIR}/php.ini"
RUN pecl install mcrypt-1.0.7 \
    && docker-php-ext-enable mcrypt;

RUN docker-php-ext-configure gd \
    && docker-php-ext-install gd

RUN docker-php-ext-install pdo pdo_mysql mysqli sockets

# Cài đặt Composer phiên bản 1.x
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Thiết lập biến môi trường để thêm thư mục bin của Composer vào $PATH
ENV PATH="${PATH}:/root/.composer/vendor/bin"