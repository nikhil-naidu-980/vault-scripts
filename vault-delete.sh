#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 <path>"
  exit 1
}

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
  usage
fi

# Assign argument to variable
TARGET_PATH=$1

# Function to recursively delete secrets and directories
delete_secrets_recursive() {
  local path=$1

  # Read the list of secrets and subdirectories from the target path
  items=$(vault kv list -format=json "$path" | jq -r '.[]')

  if [ -z "$items" ]; then
    echo "No secrets or subdirectories found at $path"
    return
  fi

  # Loop through each item
  for item in $items; do
    # Check if item is a directory (ends with a "/")
    if [[ "$item" == */ ]]; then
      # Recursively handle the subdirectory
      local sub_path="$path$item"
      echo "Entering directory $sub_path"
      delete_secrets_recursive "$sub_path"
    else
      # Delete the secret
      vault kv delete "$path$item"
      echo "Deleted secret $item at $path"
    fi
  done
}

# Call the function with the provided path
delete_secrets_recursive "$TARGET_PATH"
