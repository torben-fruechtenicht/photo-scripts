#! /usr/bin/env bash

set -e

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"

declare -r CREATE_SIDECAR="$TESTDIR/../../profile-builder/create_sidecar"

declare -r WORKING_DIR="$TESTDIR/photos"
declare -r TEMPLATES_DIR="$TESTDIR/templates"

declare -r CREATOR="Me myself and I"


find "$WORKING_DIR" -type f -name '*.pp3' -delete

"$CREATE_SIDECAR" -v -c "$CREATOR" "$TEMPLATES_DIR" "$WORKING_DIR/*"

echo "---"
find "$WORKING_DIR" -type f 

# TODO
# save correct output files in expected dir, retain directory structure (relative to TESTDIR)
# after completion, check if all files from expected match their respective counterparts in WORKING_DIR