#! /usr/bin/env bash

set -e
. "$(dirname "$(readlink -e "$0")")/../setup.sh"

assert_jpg_itpc_matches_expected() {
    cd "$EXPECTED_DIR" && find . -type f -name '*.jpg.iptc' | while read -r expected_file; do
        actual_file=${expected_file%.*}
        actual_iptc=$(exiv2 -PIkt $actual_file 2> /dev/null)
        if ! cmp -s <(echo "$actual_iptc") "$expected_file"; then
            echo "[FAIL] Actual JPEG IPTC does not match expected: $(diff <(echo "$actual_iptc") "$expected_file")" 
            exit 1
        fi
    done
} 

rsync -a "$INPUT_DIR/" "$OUTPUT_DIR"

declare -r SET_IPTC_KEYWORDS="$PROJECT_ROOT/set_iptc_keywords"

declare -r KEYWORDS="TODO;TODO 2"

find "$OUTPUT_DIR" -type f -name '*.ORF' | xargs "$SET_IPTC_KEYWORDS" -v "$KEYWORDS" 


assert_jpg_itpc_matches_expected
assert_actual_output_matches_expected "pp3"