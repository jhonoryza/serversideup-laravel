ARG PHP_VERSION
ARG WORKER

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

