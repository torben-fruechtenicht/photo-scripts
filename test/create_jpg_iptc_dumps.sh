#! /usr/bin/env bash

set -eux

declare -r OUTPUT_DIR=$(readlink -e "$1")
declare -r EXPECTED_DIR=$(readlink -e "$OUTPUT_DIR/../expected")

cd "$OUTPUT_DIR" && find . -type f -iname '*.jpg' | while read -r jpg_file; do    
    test -e "$EXPECTED_DIR/$(dirname "$jpg_file")" || mkdir --parents "$EXPECTED_DIR/$(dirname "$jpg_file")"
    exiv2 -PIkt "$jpg_file" > "$EXPECTED_DIR/$jpg_file.iptc"
done