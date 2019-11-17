#! /usr/bin/env bash

set -ex

declare -r TESTDIR="$(dirname "$(readlink -e "$0")")"

declare -r SET_IPTC_KEYWORDS="$TESTDIR/../../set_iptc_keywords"

declare -r INPUT="$TESTDIR/input"

declare -r OUTPUT="$TESTDIR/output"
(! test -e "$OUTPUT" && mkdir "$OUTPUT") || find "$OUTPUT" -type f -delete

rsync -a "$INPUT/" "$OUTPUT"

declare -r KEYWORDS="TODO"
find "$OUTPUT" -type f -name '*.ORF' | xargs "$SET_IPTC_KEYWORDS" "$KEYWORDS" 

echo "---"
find "$OUTPUT" -type f 