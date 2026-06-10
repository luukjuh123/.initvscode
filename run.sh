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

# The tarball is published as a GitHub release asset (too large to commit to git).
# Download it if it is not already present next to this script.
TARBALL="vscode-server-linux-x64.tar.gz"
TARBALL_URL="https://github.com/luukjuh123/.initvscode/releases/download/latest/$TARBALL"

if [[ ! -f "$TARBALL" ]]; then
    echo "Tarball not found locally, downloading from GitHub release..."
    if command -v wget >/dev/null 2>&1; then
        wget -O "$TARBALL" "$TARBALL_URL"
    else
        curl -fL -o "$TARBALL" "$TARBALL_URL"
    fi
    if [[ $? -ne 0 || ! -s "$TARBALL" ]]; then
        echo "Error: failed to download $TARBALL from $TARBALL_URL"
        rm -f "$TARBALL"
        exit 1
    fi
fi

# Ensure a clean installation by removing any existing version
if [[ -d "$VSCODE_SERVER_DIR" ]]; then
    echo "Removing existing VSCode server for commit $COMMIT_VERSION..."
    rm -rf "$VSCODE_SERVER_DIR"
fi

# Create the directory structure with correct user ownership
mkdir -p "$VSCODE_SERVER_DIR"
chown -R "$VSCODE_USER":"$VSCODE_USER" "$VSCODE_SERVER_PATH"

# Extract VSCode Server to a temporary location
echo "Extracting VSCode server..."
TMP_DIR=$(mktemp -d)
tar -xzf vscode-server-linux-x64.tar.gz -C "$TMP_DIR"

# Ensure the extracted directory exists
EXTRACTED_DIR="$TMP_DIR/vscode-server-linux-x64"
if [[ ! -d "$EXTRACTED_DIR" ]]; then
    echo "Error: Extraction failed or wrong structure!"
    ls -l "$TMP_DIR"
    exit 1
fi

# Move extracted files to the correct location
mv "$EXTRACTED_DIR"/* "$VSCODE_SERVER_DIR"

# Verify files moved correctly
if [[ ! -f "$VSCODE_SERVER_DIR/bin/code-server" && ! -f "$VSCODE_SERVER_DIR/node" ]]; then
    echo "Error: VSCode server was not installed correctly!"
    ls -l "$VSCODE_SERVER_DIR"
    exit 1
fi

# Ensure correct permissions
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
