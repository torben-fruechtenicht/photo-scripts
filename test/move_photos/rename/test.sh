#! /usr/bin/env bash

set -e

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"

declare -r RENAME="$TESTDIR/../../../rename"

declare -r ORIG_PHOTOS="$TESTDIR/orig"
declare -r WORKING_DIR="$TESTDIR/renamed"

declare -r NEW_NAME="Great-Photos"

! test -e "$WORKING_DIR" && mkdir "$WORKING_DIR"
find "$WORKING_DIR" -type f -delete
rsync -a "$ORIG_PHOTOS/" "$WORKING_DIR"

find "$WORKING_DIR" -type f -name '*.ORF' | xargs "$RENAME" "$NEW_NAME" 

echo "---"
find "$WORKING_DIR" -type f 

