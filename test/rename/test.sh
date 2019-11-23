#! /usr/bin/env bash

set -e
. "$(dirname "$(readlink -e "$0")")/../setup.sh"

declare -r RENAME="$PROJECT_ROOT/rename"

rsync -a "$INPUT_DIR/" "$OUTPUT_DIR"


declare -r NEW_NAME="Great-Photos"
find "$OUTPUT_DIR" -type f -name '*.ORF' | xargs "$RENAME" "$NEW_NAME" 


assert_created_files_match_expected
