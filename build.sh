#!/bin/bash

# Function to prompt until non-empty input is provided
function prompt_with_default {
	local prompt_message="$1"
	local default_value="$2"
	local input

	while true; do
		read -p "$prompt_message" input
		input=${input:-$default_value}

		if [ -n "$input" ]; then
			break
		else
			echo "Input is required. Please provide a value."
		fi
	done

	echo "$input"
}

options=("worker" "horizon")

# Prompt the user php container name
name=$(prompt_with_default "Enter image name: (example: laravel-app:latest)")
# read -p "Enter your build image name (default: laravel-app:latest): " image_name
# image_name=${image_name:-laravel-app:latest}

# Prompt the user php version
php=$(prompt_with_default "Enter your php version (example: 8.0):")

PS3="Select your worker: "
select choice in "${options[@]}"; do
	case $choice in
	"worker")
		worker="worker"
		break
		;;
	"horizon")
		worker="horizon"
		break
		;;
	*)
		echo "Invalid option."
		exit 1
		;;
	esac
done

# Prompt the user worker choice
# worker=$(prompt_with_default "Enter your worker (example: horizon or worker):")

# Prompt the user laravel environment
laravel_env=$(prompt_with_default "Enter your encoded laravel env:")

docker build --build-arg="LARAVEL_ENV=$laravel_env" --build-arg="PHP_VERSION=$php" --build-arg="WORKER=$worker" -t $image_name .
