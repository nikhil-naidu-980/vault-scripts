# Assign arguments to variables
SOURCE_PATH=$1
DESTINATION_PATH=$2

# Function to recursively copy secrets
copy_secrets_recursive() {
  local source=$1
  local destination=$2

  # Read the list of secrets and subdirectories from the source path
  items=$(vault kv list -format=json "$source" | jq -r '.[]')

  if [ -z "$items" ]; then
    echo "No secrets or subdirectories found at $source"
    exit 1
  fi

  # Loop through each item
  for item in $items; do
    # Check if item is a directory (ends with a "/")
    if [[ "$item" == */ ]]; then
      # Recursively handle the subdirectory
      local sub_source="$source$item"
      local sub_destination="$destination$item"
      
      # Create the destination directory
      vault kv put "$sub_destination" dummy_key=dummy_value > /dev/null 2>&1
      vault kv delete "$sub_destination" > /dev/null 2>&1
      
      echo "Entering directory $sub_source"
      copy_secrets_recursive "$sub_source" "$sub_destination"
    else
      # Read the secret data and write the secret data to the destination
      vault kv get -format=json -field=data "$source$item" | vault kv put "$destination$item" -
    
      echo "Copied $item from $source to $destination"
    fi
  done
}

# Call the function with provided paths
copy_secrets_recursive "$SOURCE_PATH" "$DESTINATION_PATH"
