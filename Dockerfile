ARG PHP_VERSION
ARG WORKER

FROM serversideup/php:${PHP_VERSION}-fpm-nginx as base

# install some packages
#RUN apt update -y && apt install vim curl -y

# copy Application
WORKDIR /var/www/html/
COPY ./src ./

# copy Application Environment
#COPY ./env-prod .env

# install vendor
RUN composer install --optimize-autoloader --no-interaction --no-plugins --no-scripts --prefer-dist --no-dev

# Application optimization
#RUN php artisan key:generate
#RUN php artisan clear-compiled
#RUN php artisan optimize

# Publish Laravel LiveWire assets
# you can comment this two lines if not using laravel/livewire package
#RUN php artisan livewire:publish --assets
#RUN php artisan livewire:discover

# Overide permission
RUN chown -R webuser:webgroup ./
RUN chmod -R 775 storage/

# Scheduler
RUN mkdir -p /etc/s6-overlay/s6-rc.d/scheduler
COPY ./scheduler /etc/s6-overlay/s6-rc.d/scheduler/run
RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/scheduler/type
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/scheduler

# Horizon
FROM base as queuehorizon
WORKDIR /var/www/html/

RUN mkdir -p /etc/s6-overlay/s6-rc.d/horizon
COPY ./horizon /etc/s6-overlay/s6-rc.d/horizon/run
RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/horizon/type
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/horizon

# Worker
FROM base as queueworker
WORKDIR /var/www/html/

RUN mkdir -p /etc/s6-overlay/s6-rc.d/worker
COPY ./worker /etc/s6-overlay/s6-rc.d/worker/run
RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/worker/type
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/worker

FROM queue${WORKER} as final
WORKDIR /var/www/html/

RUN chmod -R 755 /etc/s6-overlay/

