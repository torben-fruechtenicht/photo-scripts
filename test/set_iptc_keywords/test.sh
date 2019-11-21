#! /usr/bin/env bash

set -e
. ../setup.sh

rsync -a "$INPUT_DIR/" "$OUTPUT_DIR"

declare -r SET_IPTC_KEYWORDS="$PROJECT_ROOT/set_iptc_keywords"

declare -r KEYWORDS="TODO;TODO 2"

find "$OUTPUT_DIR" -type f -name '*.ORF' | xargs "$SET_IPTC_KEYWORDS" -v "$KEYWORDS" 

echo "---"
find "$OUTPUT_DIR" -type f 