#! /usr/bin/env bash

set -e
. "$(dirname "$(readlink -e "$0")")/../setup.sh"


# FIXME having to add the extra parent dir is stupid, let's just use a simple one-level
# directory layout
declare -r ARCHIVE_PROCESSED="$PROJECT_ROOT/archive_processed"

declare -r INCOMING_DIR="$OUTPUT_DIR/incoming"
declare -r ARCHIVE_DIR="$OUTPUT_DIR/archive"

test -e "$INCOMING_DIR" || mkdir "$INCOMING_DIR"
test -e "$ARCHIVE_DIR" || mkdir "$ARCHIVE_DIR"
rsync -a "$INPUT_DIR/" "$INCOMING_DIR"


"$ARCHIVE_PROCESSED" "$INCOMING_DIR" "$ARCHIVE_DIR"


assert_created_files_match_expected
