#! /usr/bin/env bash

# TBD how to handle baselines for jpg vs raw files?
# -> expect qualifier in baseline filename, e.g. "baseline_jpg" or "baseline_crw"
# -> qualifier is added to output filenames, done?

set -ue

PATH=$(dirname "$0"):$PATH
declare -r SELF=$(readlink -e "$0")

declare -r BASELINE_PP3=$(readlink -e "$1")
if [[ -z "$BASELINE_PP3" ]]; then
    echo "Missing baseline" >&2
    exit 1
fi

declare -r WORKING_DIR=$(dirname "$BASELINE_PP3")

declare -r INPUT_PROFILE=$(readlink -e "$2")
if [[ -z "$INPUT_PROFILE" ]]; then
    echo "Missing input profile" >&2
    exit 1
fi

if [[ -z $(readlink -e "$3") ]]; then
    echo "Creating missing target directory $(readlink -f "$3")" >&2
    mkdir "$(readlink -f "$3")"
fi
declare -r TARGET_DIR=$(readlink -e "$3")
declare -r OUTPUT_PROFILE=$TARGET_DIR/template.pp3
if [[ -e "$OUTPUT_PROFILE" ]]; then
    echo "Output profile $OUTPUT_PROFILE exists"
    exit 1
fi

# step 1: create the output profile for the current baseline
echo "$INPUT_PROFILE $BASELINE_PP3 $OUTPUT_PROFILE"
cp "$INPUT_PROFILE" "$OUTPUT_PROFILE"
meld_baseline.sh "$BASELINE_PP3" "$OUTPUT_PROFILE"

# step 2: check if there are baselines in sub directories of WORKING_DIR. if yes, recurse to each of these directories, 
# passing the OUTPUT_PROFILE as the next INPUT_PROFILE
declare -r next_input_profile=$OUTPUT_PROFILE
find "$WORKING_DIR" -mindepth 2 -maxdepth 2 -name 'baseline.pp3' |\
    while read next_baseline; do
        next_working_dir=$(dirname "$next_baseline")
        next_target_directory="$TARGET_DIR/${next_working_dir##*/}"
        $SELF "$next_baseline" "$next_input_profile" "$next_target_directory"
    done