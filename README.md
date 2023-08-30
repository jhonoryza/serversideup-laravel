# Laravel Single Docker Image Alternative

base image using image from serversideup/php 
this single docker image already contains nginx, php-fpm, scheduler and queue (worker or horizon)
all this process worked using s6-overlay

## Getting Started

- clone this repository

    ```bash
    git clone https://github.com/jhonoryza/serversideup-laravel.git
    cd serversideup-laravel
    ```
- clone your laravel app repository to src folder

    ```bash
    git clone https://github.com/laravel/laravel.git src
    ```
- build docker image

    ```bash
    docker build --build-arg="PHP_VERSION=8.0" --build-arg="WORKER=worker" -t laravel-app:latest .
    ``` 

you can change WORKER argument to `horizon` if you are using horizon   

- after build docker image successfully create `env` file, and fill it with your laravel env variables

- check docker-compose.yml file, you can adjust networks or ports as you want

- running the container 

```bash
  docker-compose up -d
```

- to stop the container 

```bash
  docker-compose down
```

## Some reference about s6-overlay
- https://darkghosthunter.medium.com/how-to-understand-s6-overlay-v3-95c81c04f075
- https://github.com/just-containers/s6-overlay
- https://serversideup.net/open-source/docker-php/docs/getting-started/these-images-vs-others#whats-s6-overlay

## Screenshot ps -ax from the container
![image](https://github.com/jhonoryza/serversideup-laravel/assets/5910636/1940de11-2722-4faa-8826-169310d41bd3)

