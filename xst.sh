#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

RESULTS_FOLDER="results"

# Function to show a spinner while waiting
spinner() {
    local pid=$1
    local delay=0.15
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to perform TRACE request for a single target
perform_trace_single() {
    local target="$1"

    response=$(curl -X TRACE -H "$custom_header" -s -w "%{http_code}" --max-time 5 "$target")

    http_code="${response: -3}" # Extract the HTTP status code

    if [[ "$http_code" == "200" ]]; then
        echo -e "${GREEN}$target - Valid${NC}"
        mkdir -p "$RESULTS_FOLDER"  # Create the "results" folder if it doesn't exist
        echo "$target" >> "$RESULTS_FOLDER/valid.txt"  # Save the valid target to the file
    elif [[ "$http_code" == "405" ]]; then
        echo -e "$target - ${RED}Method Not Allowed${NC}"
    else
        echo -e "$target - ${RED}Unexpected response. HTTP Status Code: $http_code${NC}"
    fi
}

# Function to perform TRACE request for multiple targets from a list
perform_trace_list() {
    local target_list="$1"
    echo -e "\nSending TRACE requests to targets from $target_list:"
    while IFS= read -r target; do
        perform_trace_single "$target"
    done < "$target_list"
}

# Check if the mode is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <mode> <target or target_list>"
    echo -e "\nModes:"
    echo "  1. single <target>"
    echo "  2. list <target_list>"
    exit 1
fi

mode="$1"

# Target(s)
if [ "$mode" == "single" ]; then
    if [ -z "$2" ]; then
        echo "Usage: $0 single <target>"
        exit 1
    fi
    target="$2"
    perform_trace_single "$target"

elif [ "$mode" == "list" ]; then
    if [ -z "$2" ]; then
        echo "Usage: $0 list <target_list>"
        exit 1
    fi
    target_list="$2"
    perform_trace_list "$target_list"

else
    echo "Invalid mode. Please use 'single' or 'list'."
    exit 1
fi

echo -e "\nDone."

