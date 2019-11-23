#! /usr/bin/env bash

set -e

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"

declare -r MOVE_TO_ALBUM="$TESTDIR/../../move_to_album"

declare -r INPUT_DIR="$TESTDIR/input"
declare -r OUTPUT_DIR="$TESTDIR/output"

declare -r NEW_NAME="Great-Photos"

! test -e "$OUTPUT_DIR" && mkdir "$OUTPUT_DIR"
find "$OUTPUT_DIR" -type f -delete
rsync -a "$INPUT_DIR/" "$OUTPUT_DIR"

find "$OUTPUT_DIR" -type f -name '*.ORF' | xargs "$MOVE_TO_ALBUM" "$OUTPUT_DIR/2019/Other-album" 

echo "---"
find "$OUTPUT_DIR" -type f 

