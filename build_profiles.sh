#! /usr/bin/env bash

set -ue

PATH=$(dirname "$0"):$PATH
SELF=$(readlink -e "$0")

declare -r BASELINE_PP3=$(readlink -e "$1")
if [[ -z "$BASELINE_PP3" ]]; then
    echo "Missing baseline" >&2
    exit 1
fi

declare -r INPUT_PROFILE=$(readlink -e "$2")
if [[ -z "$INPUT_PROFILE" ]]; then
    echo "Missing input profile" >&2
    exit 1
fi

declare -r OUTPUT_PROFILE=$(readlink -f "$3")
if [[ -z "$OUTPUT_PROFILE" ]]; then
    echo "Output profile path does not exist" >&2
    exit 1
fi
if [[ -e "$OUTPUT_PROFILE" ]]; then
    echo "Output profile $OUTPUT_PROFILE already exists"
    exit 1
fi

cp "$INPUT_PROFILE" "$OUTPUT_PROFILE"
meld_baseline.sh "$BASELINE_PP3" "$OUTPUT_PROFILE"

find "$(dirname "$BASELINE_PP3")" -mindepth 2 -maxdepth 2 -name 'baseline.pp3' |\
    while read next_baseline; do
        $SELF "$next_baseline" "$OUTPUT_PROFILE" "$(dirname "$next_baseline")/template.pp3"
    done



