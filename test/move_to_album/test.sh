#! /usr/bin/env bash

set -e
. "$(dirname "$(readlink -e "$0")")/../setup.sh"

declare -r MOVE_TO_ALBUM="$PROJECT_ROOT/move_to_album"

rsync -a "$INPUT_DIR/" "$OUTPUT_DIR"

# declare -r NEW_NAME="Great-Photos"
find "$OUTPUT_DIR" -type f -name '*.ORF' | xargs "$MOVE_TO_ALBUM" "$OUTPUT_DIR/2019/Other-album" 


assert_created_files_match_expected

