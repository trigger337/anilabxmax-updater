#!/bin/bash

# Constants
REPO_API_URL="https://api.github.com/repos/AniLabX/AniLabXMAX/releases/latest"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_BINARY_PATH=$(find "$SCRIPT_DIR" -maxdepth 1 -name '*_linux64' -type f)

# Fetch the latest release information
echo "Fetching the latest release information..."
response=$(curl -s $REPO_API_URL)

# Extract the download URL for the linux64 binary
echo "Finding the linux64 binary..."
download_url=$(echo "$response" | jq -r '.assets[] | select(.name | endswith("_linux64")) | .browser_download_url')

# Check if a Linux 64 binary exists in assets
if [[ -z "$download_url" ]]; then
  echo "Could not find a linux64 binary in the latest release."
  exit 1
fi

# Extract the new binary name
new_binary_name=$(basename $download_url)
new_binary_path="${SCRIPT_DIR}/${new_binary_name}"

# Download the new binary
echo "Downloading the new binary..."
curl -L "$download_url" -o "$new_binary_path"

# Remove the current binary if it exists
if [[ -f "$CURRENT_BINARY_PATH" ]]; then
  echo "Removing the current binary..."
  rm "$CURRENT_BINARY_PATH"
fi

# Move the new binary to the current binary path
echo "Updating the binary..."
mv "$new_binary_path" "$SCRIPT_DIR"

# Set executable permissions on the new binary
echo "Setting executable permissions..."
chmod +x "${SCRIPT_DIR}/${new_binary_name}"

echo "Update completed: ${SCRIPT_DIR}/${new_binary_name}"
