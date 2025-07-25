#! /usr/bin/env bash

# This script undoes the effects of `./nginx-dev-setup.sh`
#
# WARNING: This script is destructive. It deletes files and kills processes.
#
# READ IT CAREFULLY BEFORE RUNNING

# Get the file location of this script
# Credit for this one-liner: https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# If you change any of these variables, make sure to also change their
# counterparts in `./nginx-dev-setup.sh`
PROJECT_ROOT="$SCRIPT_DIR/.."
NGINX_ROOT="/tmp-nginx"
NGINX_CONFIG="$SCRIPT_DIR/nginx-dev.conf"
NGINX_LOG_DIR="/var/log/nginx"

echo "WARNING - This script will:"
echo "- Kill Nginx"
echo "- Unmount $NGINX_ROOT"
echo "- Delete $NGINX_ROOT"
echo "- Delete $NGINX_LOG_DIR"
echo
read -p "Are you sure you want to do this? (y/N) " -n 1 -r
echo
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Stop nginx
    sudo nginx -c "$NGINX_CONFIG" -s stop &>/dev/null

    # Make sure nginx has stopped before moving on
    echo "Waiting for Nginx to stop..."
    while pgrep nginx > /dev/null; do sleep 1; done
    echo "Nginx has stopped."

    # Unmount bind filesystem
    until sudo umount "$NGINX_ROOT"; do
        echo "Unmounting $NGINX_ROOT failed, retrying in 5 seconds..."
        sleep 5
    done
    echo "$NGINX_ROOT unmounted successfully"

    echo "Deleting log directory ($NGINX_LOG_DIR)"
    sudo rm -rf "$NGINX_LOG_DIR"

    # Delete $NGINX_ROOT but ONLY if it is empty
    if [ -z "$( ls -A "$NGINX_ROOT" )" ]; then
        echo "Deleting $NGINX_ROOT"
        sudo rm -rf "$NGINX_ROOT"
    else
        echo "WARNING: $NGINX_ROOT is NOT empty and so won't be deleted."
    fi
fi
