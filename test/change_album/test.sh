#! /usr/bin/env bash

set -e

source "$(dirname "$(readlink -e "$0")")/../setup.sh"

PATH="$PROJECT_ROOT:$PATH"

rsync -a "$INPUT_DIR/" "$OUTPUT_DIR"

declare -r TARGET_ALBUM_NAME="Other-album"
find "$OUTPUT_DIR" -type f -name '*.ORF' | change_album "$TARGET_ALBUM_NAME"

assert_created_files_match_expected
