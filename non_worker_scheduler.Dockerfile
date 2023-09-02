ARG PHP_VERSION

FROM serversideup/php:${PHP_VERSION}-fpm-nginx as base

# copy Application
WORKDIR /var/www/html/
COPY ./src ./

# copy Application Environment
ARG LARAVEL_ENV
ENV LARAVEL_ENV=${LARAVEL_ENV}
RUN echo $LARAVEL_ENV > encoded-env
RUN base64 -d encoded-env > .env
RUN rm encoded-env

# install vendor
RUN composer install --optimize-autoloader --no-interaction --no-plugins --no-scripts --prefer-dist --no-dev

# Overide permission
RUN chown -R webuser:webgroup ./
RUN chmod -R 775 storage/

RUN chmod -R 755 /etc/s6-overlay/

