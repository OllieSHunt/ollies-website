#! /usr/bin/env bash

# This is a script that uses bindfs to create a place for nginx to serve this
# website from with the correct file permissions.
#
# It is intended for debugging as the server side includes I use don't work
# when you just open up the HTML file in your browser.
#
# If everything is set up correctly, you should be able to view the website at
# `http://localhost/`.
#
# This script was written, tested, and confirmed working on NixOS
#
# Script Dependencies:
# - bash
# - bindfs
# - nginx (setup to look in `/nginx` for a website to serve and configured with "ssi on;")
# - systemd

# Get the file location of this script
# One-liner credit: https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

NGINX_ROOT="/nginx"

sudo mkdir $NGINX_ROOT
sudo chown nginx:nginx $NGINX_ROOT
sudo bindfs -u nginx -g nginx $SCRIPT_DIR $NGINX_ROOT
sudo systemctl restart nginx.service
