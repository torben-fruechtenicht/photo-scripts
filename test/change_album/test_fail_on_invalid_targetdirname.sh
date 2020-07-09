#! /usr/bin/env bash

set -e

source "$(dirname "$(readlink -e "$0")")/../setup.sh"

PATH="$PROJECT_ROOT:$PATH"

declare -r TARGET_ALBUM_NAME="$OUTPUT_DIR"
set -o pipefail
! find "$OUTPUT_DIR" -type f -name '*.ORF' | change_album "$TARGET_ALBUM_NAME" -