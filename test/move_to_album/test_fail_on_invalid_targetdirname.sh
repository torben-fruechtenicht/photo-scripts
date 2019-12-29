#! /usr/bin/env bash

set -e
. "$(dirname "$(readlink -e "$0")")/../setup.sh"

declare -r MOVE_TO_ALBUM="$PROJECT_ROOT/move_to_album"

rsync -a "$INPUT_DIR/" "$OUTPUT_DIR"


declare -r TARGET_ALBUM_NAME="$OUTPUT_DIR"
find "$OUTPUT_DIR" -type f -name '*.ORF' | xargs "$MOVE_TO_ALBUM" "$TARGET_ALBUM_NAME" 
assert_count_of_output_files_is 2

