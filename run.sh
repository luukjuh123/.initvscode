#!/bin/bash

######################################################################
## Script for setting up the vscode server on the vm
######################################################################

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Read the commit version from version.txt
if [[ ! -f version.txt ]]; then
    echo "version.txt not found!"
    exit 1
fi

COMMIT_VERSION=$(cat version.txt)
echo "Using commit version: $COMMIT_VERSION"

mkdir -p ~/.vscode-server/bin/$COMMIT_VERSION
tar -xzf vscode-server-linux-x64.tar.gz -C ~/.vscode-server/bin/$COMMIT_VERSION

chmod -R 777 ~/.vscode-server/bin
chmod -R 777 ~/.vscode-server
