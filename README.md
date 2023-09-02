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
    composer create-project laravel/laravel src
    ```

- create `env` file, and fill it with your laravel env variables

- check docker-compose.yml file, you can adjust networks, ports, image and container name as you want

- build docker image run `./build.sh`

- running the container 

```bash
  docker-compose up -d
```

- to stop the container 

```bash
  docker-compose down
```

## Running artisan command

- you need to login to the container using this command 

```bash
  docker exec -it -u webuser laravel-app bash
```

which laravel-app is the container name, you need to change these if you change the container name 

- some common artisan commands:

```bash
  php artisan key:generate
  php artisan clear-compiled
  php artisan optimize
  php artisan cache:clear 
  php artisan config:clear 
  php artisan route:clear 
  php artisan view:clear 
  
  php artisan livewire:publish --assets
  php artisan livewire:discover
```

## Some reference about s6-overlay
- https://darkghosthunter.medium.com/how-to-understand-s6-overlay-v3-95c81c04f075
- https://github.com/just-containers/s6-overlay
- https://serversideup.net/open-source/docker-php/docs/getting-started/these-images-vs-others#whats-s6-overlay

## Screenshot ps -ax from the container
![image](https://github.com/jhonoryza/serversideup-laravel/assets/5910636/1940de11-2722-4faa-8826-169310d41bd3)

