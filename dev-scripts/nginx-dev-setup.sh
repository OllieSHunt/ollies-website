#! /usr/bin/env bash

# This is a script that sets up a Nginx server on your local computer for
# debugging.
#
# This is needed because SSI (Server Side Includes) does not work when you
# just open up the HTML file in your browser.
#
# If everything is set up correctly, you should be able to view the website at
# `http://localhost/` or from another device with `http://<YOUR_IP>`.
#
# IMPORTANT: You can clean up all temp files created by this script using
# `./nginx-dev-cleanup.sh`
#
# This script was written, tested, and confirmed working on NixOS.
#
# Script Dependencies:
# - bash
# - nginx

# Get the file location of this script
# Credit for this one-liner: https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# If you change any of these variables, make sure to also change their
# counterparts in `./nginx-dev-cleanup.sh`
PROJECT_ROOT="$SCRIPT_DIR/.."
NGINX_ROOT="/tmp-nginx"
NGINX_CONFIG="$SCRIPT_DIR/nginx-dev.conf"
NGINX_LOG_DIR="/var/log/nginx"
USER=$(id -nu)
GROUP=$(id -ng)

# Exit if important directory is already in use
if ! [ -z "$( ls -A "$NGINX_ROOT" 2>/dev/null )" ]; then
    echo "ERROR: $NGINX_ROOT is NOT empty and so should not have anything mounted over the top of it."
    exit 1
fi

# Create mount point
sudo mkdir -p "$NGINX_ROOT"
sudo chown "$USER:$GROUP" "$NGINX_ROOT"

# Bind mount
sudo mount --bind $PROJECT_ROOT "$NGINX_ROOT"

# Create log files directory
sudo mkdir -p "$NGINX_LOG_DIR"

# Start nginx
sudo nginx -c "$NGINX_CONFIG"
