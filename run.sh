#!/bin/bash

######################################################################
## Script for setting up the VSCode server on the VM
######################################################################

# Ensure the script runs with root permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Define the non-root user running VSCode
VSCODE_USER="${SUDO_USER:-$(whoami)}"
VSCODE_HOME=$(eval echo "~$VSCODE_USER")  # Gets the correct home directory for the user
VSCODE_SERVER_PATH="$VSCODE_HOME/.vscode-server"

# Read the commit version from version.txt
if [[ ! -f version.txt ]]; then
    echo "Error: version.txt not found!"
    exit 1
fi

COMMIT_VERSION=$(cat version.txt | tr -d '[:space:]')  # Remove spaces/newlines
echo "Using commit version: $COMMIT_VERSION"

# Define the VSCode server directory
VSCODE_SERVER_DIR="$VSCODE_SERVER_PATH/bin/$COMMIT_VERSION"

# Ensure the VSCode server tarball exists
if [[ ! -f vscode-server-linux-x64.tar.gz ]]; then
    echo "Error: vscode-server-linux-x64.tar.gz not found!"
    exit 1
fi

# Ensure a clean installation by removing any existing version
if [[ -d "$VSCODE_SERVER_DIR" ]]; then
    echo "Removing existing VSCode server for commit $COMMIT_VERSION..."
    rm -rf "$VSCODE_SERVER_DIR"
fi

# Create the directory structure with correct user ownership
mkdir -p "$VSCODE_SERVER_DIR"
chown -R "$VSCODE_USER":"$VSCODE_USER" "$VSCODE_SERVER_PATH"

# Extract VSCode Server
echo "Extracting VSCode server to $VSCODE_SERVER_DIR..."
tar -xzf vscode-server-linux-x64.tar.gz -C "$VSCODE_SERVER_DIR"

# Verify extraction was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Extraction failed!"
    exit 1
fi

# Verify that the required server file exists
SERVER_SCRIPT="$VSCODE_SERVER_DIR/server.sh"
if [[ ! -f "$SERVER_SCRIPT" ]]; then
    echo "Error: VSCode server installation seems incorrect. Missing server.sh in $VSCODE_SERVER_DIR"
    exit 1
fi

# Ensure the server script is executable
chmod +x "$SERVER_SCRIPT"

# Double-check that the correct commit version exists in the expected location
if [[ ! -d "$VSCODE_SERVER_PATH/bin/$COMMIT_VERSION" ]]; then
    echo "Error: VSCode Server is NOT in the expected location!"
    exit 1
else
    echo "VSCode Server successfully installed at: $VSCODE_SERVER_PATH/bin/$COMMIT_VERSION"
fi

# Ensure correct permissions for execution
chmod -R 755 "$VSCODE_SERVER_DIR"
chmod -R 755 "$VSCODE_SERVER_PATH"
chown -R "$VSCODE_USER":"$VSCODE_USER" "$VSCODE_SERVER_PATH"

# Set environment variables to prevent VSCode from re-downloading the server
echo "Configuring environment variables..."
export VSCODE_UPDATE_MODE=none
export VSCODE_SERVER_DIR="$VSCODE_SERVER_PATH"

# Final verification: Manually list installed versions
echo "Verifying installed VSCode server versions..."
ls -l "$VSCODE_SERVER_PATH/bin/"

# Display success message
echo "✅ VSCode Server setup completed successfully! Ready to connect."
