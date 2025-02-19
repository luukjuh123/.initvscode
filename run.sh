#!/bin/bash

######################################################################
## Script for setting up the VSCode server on the VM
######################################################################

# Ensure the script runs with root permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Read the commit version from version.txt
if [[ ! -f version.txt ]]; then
    echo "Error: version.txt not found!"
    exit 1
fi

COMMIT_VERSION=$(cat version.txt | tr -d '[:space:]')  # Remove any unwanted spaces or newlines
echo "Using commit version: $COMMIT_VERSION"

# Define the VSCode server directory
VSCODE_SERVER_DIR="$HOME/.vscode-server/bin/$COMMIT_VERSION"

# Ensure previous installation is removed if it exists (optional, but ensures clean install)
if [[ -d "$VSCODE_SERVER_DIR" ]]; then
    echo "Removing existing VSCode server for commit $COMMIT_VERSION..."
    rm -rf "$VSCODE_SERVER_DIR"
fi

# Create the directory structure
mkdir -p "$VSCODE_SERVER_DIR"

# Verify the archive file exists
if [[ ! -f vscode-server-linux-x64.tar.gz ]]; then
    echo "Error: vscode-server-linux-x64.tar.gz not found!"
    exit 1
fi

# Extract VSCode Server
echo "Extracting VSCode server..."
tar -xzf vscode-server-linux-x64.tar.gz -C "$VSCODE_SERVER_DIR"

# Verify extraction was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Extraction failed!"
    exit 1
fi

# Ensure correct permissions
chmod -R 755 "$VSCODE_SERVER_DIR"
chmod -R 755 "$HOME/.vscode-server"

# Set environment variables to prevent re-downloading
echo "Configuring environment variables..."
export VSCODE_UPDATE_MODE=none
export VSCODE_SERVER_DIR="$HOME/.vscode-server"

# Display success message
echo "VSCode Server setup completed successfully!"
