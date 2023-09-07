#!/bin/bash

# Function to prompt until non-empty input is provided
function prompt_with_default {
	local prompt_message="$1"
	local default_value="$2"
	local input
        
	if [ -z "$default_value" ]; then
		while true; do
			read -p "$prompt_message" input
			input="${input:-$default_value}"

			if [ -n "$input" ]; then
				break
			else
				echo "Input is required. Please provide a value."
			fi
		done
	else 
		input=$default_value
	fi 

	echo "$input"
}

default_image_name="${1:-}"
default_php_version="${2:-}"
default_enable_scheduler="${3:-}"
default_enable_worker="${4:-}"

# Prompt image name
name=$(prompt_with_default "Enter image name. example laravel-app:latest : " "$default_image_name")

# Prompt php version
php=$(prompt_with_default "Enter your php version. example 8.0 : " "$default_php_version")

enable_scheduler=$(prompt_with_default "Enable scheduler? (y/n) : " "$default_enable_scheduler")

enable_worker=$(prompt_with_default "Enable background job? (y/n) : " "$default_enable_worker")

# Prompt worker options
if [ "$enable_worker" == "y" ]; then
	options=("worker" "horizon")
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
fi

# Read env file
env_file="$PWD/env"

# Check if the file exists and is not empty
if [ ! -f "$env_file" ]; then
	echo "Error: The specified environment file does not exist. please create env file and fill it with laravel .env"
	exit 1
fi

if [ ! -s "$env_file" ]; then
	echo "Error: The specified environment file is empty. please create env file and fill it with laravel .env"
	exit 1
fi

# encode this env file to base64
laravel_env=$(base64 -w 0 <"$env_file")

# if enable_worker and enable_scheduler are set
if [ "$enable_worker" == "y" ] && [ "$enable_scheduler" == "y" ]; then

	command_string="docker build --no-cache --build-arg=\"LARAVEL_ENV=%s\" --build-arg=\"PHP_VERSION=%s\" --build-arg=\"WORKER=%s\" -f Dockerfile -t %s ."
	formatted_command=$(printf "$command_string" "$laravel_env" "$php" "$worker" "$name")

# if enable_worker is set and enable_scheduler is not
elif [ "$enable_worker" == "y" ] && [ "$enable_scheduler" == "n" ]; then

	command_string="docker build --no-cache --build-arg=\"LARAVEL_ENV=%s\" --build-arg=\"PHP_VERSION=%s\" --build-arg=\"WORKER=%s\" -f only_worker.Dockerfile -t %s ."
	formatted_command=$(printf "$command_string" "$laravel_env" "$php" "$worker" "$name")

# if enable_scheduler is set and enable_worker is not
elif [ "$enable_scheduler" == "y" ] && [ "$enable_worker" == "n" ]; then

	command_string="docker build --no-cache --build-arg=\"LARAVEL_ENV=%s\" --build-arg=\"PHP_VERSION=%s\" -f only_scheduler.Dockerfile -t %s ."
	formatted_command=$(printf "$command_string" "$laravel_env" "$php" "$name")

# if enable_scheduler and enable_worker are not set
else

	command_string="docker build --no-cache --build-arg=\"LARAVEL_ENV=%s\" --build-arg=\"PHP_VERSION=%s\" -f non_worker_scheduler.Dockerfile -t %s ."
	formatted_command=$(printf "$command_string" "$laravel_env" "$php" "$name")

fi

# Print the formatted command
echo "run command: $formatted_command"

# Run the formatted command
eval "$formatted_command"
