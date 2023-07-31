# Laravel Single Docker Image Alternative

base image using image from serversideup/php 

this single docker image already contains nginx, php-fpm, scheduler and queue (horizon)

all this process worked using s6-overlay

## Some reference about s6-overlay
- https://darkghosthunter.medium.com/how-to-understand-s6-overlay-v3-95c81c04f075
- https://github.com/just-containers/s6-overlay
- https://serversideup.net/open-source/docker-php/docs/getting-started/these-images-vs-others#whats-s6-overlay

## Screenshot ps -ax from the container
![image](https://github.com/jhonoryza/serversideup-laravel/assets/5910636/1940de11-2722-4faa-8826-169310d41bd3)

## Before cloning your laravel aplication 
- create serversideup.Dockerfile in your laravel root dir, something like this

    ```Dockerfile
    from serversideup/php:8.0-fpm-nginx

    # install some packages
    RUN apt update -y && apt install vim curl -y
    
    # copy Application
    WORKDIR /var/www/html/
    COPY ./build ./
    
    # copy Application Environment
    COPY ./env-prod .env
    
    # install vendor
    RUN composer install --optimize-autoloader --no-interaction --no-plugins --no-scripts --prefer-dist --no-dev
    
    # Application optimization
    RUN php artisan key:generate
    RUN php artisan clear-compiled
    RUN php artisan optimize
    
    # Publish Laravel LiveWire assets
    # you can comment this two lines if not using laravel/livewire package
    RUN php artisan livewire:publish --assets
    RUN php artisan livewire:discover
    
    # Overide permission
    RUN chown -R webuser:webgroup ./
    RUN chmod -R 775 storage/
    
    # Horizon
    #COPY ./horizon /etc/s6-overlay/scripts/
    RUN mkdir -p /etc/s6-overlay/s6-rc.d/horizon
    COPY ./horizon /etc/s6-overlay/s6-rc.d/horizon/run
    #RUN echo "/etc/s6-overlay/scripts/horizon" > /etc/s6-overlay/s6-rc.d/horizon/run
    RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/horizon/type
    RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/horizon
    
    # Scheduler
    #COPY ./scheduler /etc/s6-overlay/scripts/
    RUN mkdir -p /etc/s6-overlay/s6-rc.d/scheduler
    COPY ./scheduler /etc/s6-overlay/s6-rc.d/scheduler/run
    #RUN echo "/etc/s6-overlay/scripts/scheduler" > /etc/s6-overlay/s6-rc.d/scheduler/run
    RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/scheduler/type
    RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/scheduler
    
    RUN chmod -R 755 /etc/s6-overlay/
    ```

## Getting Started

- clone your laravel aplication like this

    ```bash
    git clone {git repo url} build
    ```

- create file env-prod for your .env laravel aplication in root dir
- run `docker-compose up -d --build`
- cek your app from `http://your-domain:3200`

## Laravel .env files
- env-prod file will be copied to the container when build image process happen
- so you need to rebuild the image every time there is a changes in this file

## Laravel queue and scheduler
- scheduler is worked automaticaly in this container 
- you need `laravel/horizon` package so queue will worked automaticaly in this container, to installed it run `composer require laravel/horizon`

## Change PHP version
- you can change php version from your Dockerfile and just rebuild it
