#! /usr/bin/env bash

set -ex

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"

declare -r RENAME="$TESTDIR/../../../rename"

declare -r ORIG_PHOTOS="$TESTDIR/orig"
declare -r WORKING_DIR="$TESTDIR/renamed"

declare -r NEW_NAME="Great-Photos"

! test -e "$WORKING_DIR" && mkdir "$WORKING_DIR"
rm -rf "$WORKING_DIR/*"
rsync -a "$ORIG_PHOTOS/" "$WORKING_DIR"

find "$WORKING_DIR" -type f | xargs "$RENAME" "$NEW_NAME" 

echo "---"
find "$WORKING_DIR" -type f 

