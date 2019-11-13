#! /usr/bin/env bash

set -e

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"

declare -r CREATE_SIDECAR="$TESTDIR/../../profile-builder/create_sidecar"

declare -r WORKING_DIR="$TESTDIR/photos"
declare -r TEMPLATES_DIR="$TESTDIR/templates"


find "$WORKING_DIR" -type f -name '*.pp3' -delete

"$CREATE_SIDECAR" "$TEMPLATES_DIR" "$WORKING_DIR/*"

echo "---"
find "$WORKING_DIR" -type f 