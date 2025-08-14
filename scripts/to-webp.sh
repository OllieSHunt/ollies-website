#!/usr/bin/env bash

# This script will convert a given file to .webp
# You can pass multiple files
#
# WARNING: This script will delete the original image
#
# Script dependencies:
# - ImageMagick

for i in $(seq 1 $#); do
    file_in=${!i}
    file_out="${file_in%.*}.webp"

    echo "$file_in -> $file_out"

    # Convert files + delete original only if successful
    magick -quality 100 "$file_in" "$file_out" && rm "$file_in"
done
