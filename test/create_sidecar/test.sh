#! /usr/bin/env bash

set -e

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"
declare -r INPUT_DIR="$TESTDIR/input"
declare -r OUTPUT_DIR="$TESTDIR/output"
declare -r EXPECTED_DIR="$TESTDIR/expected"

declare -r CREATE_SIDECAR="$TESTDIR/../../profile-builder/create_sidecar"

declare -r TEMPLATES_DIR="$INPUT_DIR/templates"

declare -r CREATOR="Me myself and I"
declare -r KEYWORDS="keywordA;keyword b"

! test -e "$OUTPUT_DIR" && mkdir "$OUTPUT_DIR" || find "$OUTPUT_DIR" -type f -delete
rsync -a "$INPUT_DIR/photos/" "$OUTPUT_DIR/"

"$CREATE_SIDECAR" -v -c "$CREATOR" -k "$KEYWORDS" "$TEMPLATES_DIR" "$OUTPUT_DIR/*"

echo "---"

(( $(find "$OUTPUT_DIR" -type f -name '*.pp3' | wc -l) == 2 )) || (echo "Not all sidecars were created" && exit 1)
cd "$EXPECTED_DIR" && find . -type f | while read -r expected_file; do
    test -f "$OUTPUT_DIR/$expected_file" || (echo "Expected file $expected_file missing" && exit 1)
    cmp -s "$EXPECTED_DIR/$expected_file" "$OUTPUT_DIR/$expected_file" || (echo "Actual file does not match $expected_file" && exit 1)
done
echo "All tests ok"