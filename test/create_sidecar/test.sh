#! /usr/bin/env bash

set -e
. "$(dirname "$(readlink -e "$0")")/../setup.sh"

declare -r CREATE_SIDECAR="$PROJECT_ROOT/profile-builder/create_sidecar"

declare -r TEMPLATES_DIR="$INPUT_DIR/templates"
declare -r CREATOR="Me myself and I"
declare -r KEYWORDS="keywordA;keyword b"

rsync -a "$INPUT_DIR/photos/" "$OUTPUT_DIR/"

"$CREATE_SIDECAR" -v -c "$CREATOR" -k "$KEYWORDS" "$TEMPLATES_DIR" "$OUTPUT_DIR/*"

echo "---"

assert_correct_actual_sidecar_count 2
assert_actual_output_matches_expected