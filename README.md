# Laravel Single Docker Image Alternative

base image using image from serversideup/php 
this single docker image already contains nginx, php-fpm, scheduler and queue (worker or horizon)
all this process worked using s6-overlay

## Getting Started

- clone this repository

    ```bash
    git clone https://github.com/jhonoryza/serversideup-laravel.git
    ```

## Build Argument
- `docker compose build --build-arg PHP_VERSION=8.2 --build-arg WORKER=worker` 
- if you use horizon change to `--build-arg WORKER=horizon` 

## Some reference about s6-overlay
- https://darkghosthunter.medium.com/how-to-understand-s6-overlay-v3-95c81c04f075
- https://github.com/just-containers/s6-overlay
- https://serversideup.net/open-source/docker-php/docs/getting-started/these-images-vs-others#whats-s6-overlay

## Screenshot ps -ax from the container
![image](https://github.com/jhonoryza/serversideup-laravel/assets/5910636/1940de11-2722-4faa-8826-169310d41bd3)

