#!/usr/bin/env bash

# This script will convert favicon.svg to a .ico file.
#
# WARNING: The old favicon.ico will be overwritten.
#
# Script dependencies:
# - bash
# - inkscape
# - ImageMagick
#
# This script MUST be run from the root directory of this project.
# e.g. use `./scripts/create-favicon.sh` NOT `./create-favicon.sh`

# Useful resource:
# https://evilmartians.com/chronicles/how-to-favicon-in-2021-six-files-that-fit-most-needs#the-ultimate-favicon-setup

tmp_dir=/tmp/create-favicon
input_svg=static/favicon.svg
output_ico=static/favicon.ico
sizes=(16 32 48 128 256)
intermediaries=()

mkdir -p "$tmp_dir"

for size in "${sizes[@]}"; do
    intermediary="$tmp_dir/$size.png"
    inkscape "$input_svg" --export-width="$size" --export-filename="$intermediary"
    intermediaries+=("$intermediary")
done

magick "${intermediaries[@]}" "$output_ico"

# Cleanup
rm -rf "$tmp_dir"
