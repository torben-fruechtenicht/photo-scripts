#! /usr/bin/env bash

set -e
. "$(dirname "$(readlink -e "$0")")/../setup.sh"

rsync -a "$INPUT_DIR/" "$OUTPUT_DIR"

declare -r SET_IPTC_KEYWORDS="$PROJECT_ROOT/set_iptc_keywords"

declare -r KEYWORDS="TODO;TODO 2"

find "$OUTPUT_DIR" -type f -name '*.ORF' | xargs "$SET_IPTC_KEYWORDS" -v "$KEYWORDS" 


assert_jpg_itpc_matches_expected
assert_actual_sidecars_match_expected