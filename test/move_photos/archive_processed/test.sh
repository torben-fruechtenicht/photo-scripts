#! /usr/bin/env bash

set -e

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"

declare -r ARCHIVE_PROCESSED="$TESTDIR/../../../archive_processed"

declare -r INPUT_DIR="$TESTDIR/input"
declare -r OUTPUT_DIR="$TESTDIR/output"
declare -r INCOMING_DIR="$OUTPUT_DIR/incoming"
declare -r ARCHIVE_DIR="$OUTPUT_DIR/archive"

! test -e "$OUTPUT_DIR" && mkdir "$OUTPUT_DIR"
find "$OUTPUT_DIR" -mindepth 1 -delete
mkdir "$INCOMING_DIR"
mkdir "$ARCHIVE_DIR"
rsync -a "$INPUT_DIR/" "$INCOMING_DIR"

"$ARCHIVE_PROCESSED" "$INCOMING_DIR" "$ARCHIVE_DIR"

echo "---"
find "$OUTPUT_DIR" -type f 