#! /usr/bin/env bash

set -e

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"
declare -r INPUT_DIR="$TESTDIR/input"
declare -r OUTPUT_DIR="$TESTDIR/output"

declare -r CREATE_SIDECAR="$TESTDIR/../../profile-builder/create_sidecar"

declare -r TEMPLATES_DIR="$INPUT_DIR/templates"

declare -r CREATOR="Me myself and I"
declare -r KEYWORDS="keywordA;keyword b"

! test -e "$OUTPUT_DIR" && mkdir "$OUTPUT_DIR" || find "$OUTPUT_DIR" -type f -delete
rsync -a "$INPUT_DIR/photos/" "$OUTPUT_DIR/"

"$CREATE_SIDECAR" -v -c "$CREATOR" -k "$KEYWORDS" "$TEMPLATES_DIR" "$OUTPUT_DIR/*"

echo "---"
find "$OUTPUT_DIR" -type f | sort

# TODO
# save correct output files in expected dir, retain directory structure (relative to TESTDIR)
# after completion, check if all files from expected match their respective counterparts in WORKING_DIR