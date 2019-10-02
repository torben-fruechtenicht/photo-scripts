#! /usr/bin/env bash

# TBD how to handle baselines for jpg vs raw files?
# -> expect qualifier in baseline filename, e.g. "baseline_jpg" or "baseline_crw"
# -> qualifier is added to output filenames, done?

set -ue

declare -r SELF=$(readlink -e "$0")
declare -r MELD_BASELINE=$(dirname "$SELF")/meld_baseline.sh

declare -r WORKING_DIR=$(readlink -e "$1")
if [[ -z "$WORKING_DIR" ]]; then
    echo "Missing working dir" >&2
    exit 1
fi

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
    echo "Output profile $OUTPUT_PROFILE exists" >&2
    exit 1
fi

# scan WORKING_DIR for baseline files, with or without filetype qualifier in the filename (e.g. both "baseline.pp3"
# and "baseline.raw.pp3") will be processed. each baseline file is processed, afterwards filetype qualifier is used
# when looking for more related baseline in subdirectories (i.e. only baselines with same qualifier are matched)
find "$WORKING_DIR" -mindepth 1 -maxdepth 1 -type f -regex '.*baseline\(..*\)?.pp3' |\
    while read baseline; do
        baseline_filename=$(basename "$baseline")
        output_profile=$TARGET_DIR/${baseline_filename/baseline/template}
        # TODO check if output profile exists - exit if yes? only skip? skip but recurse?

        # step 1: create the output profile for the current baseline
        echo "$INPUT_PROFILE $baseline $output_profile"
        cp "$INPUT_PROFILE" "$output_profile"
        $MELD_BASELINE -v "$baseline" "$output_profile"

        # step 2: check if there are baselines in sub directories of WORKING_DIR. if yes, recurse to each of these directories, 
        # passing the OUTPUT_PROFILE as the next INPUT_PROFILE
        next_input_profile=$output_profile
        find "$WORKING_DIR" -mindepth 2 -maxdepth 2 -name "$baseline_filename" |\
            while read next_baseline; do
                next_working_dir=$(dirname "$next_baseline")
                next_target_directory="$TARGET_DIR/${next_working_dir##*/}"
                $SELF "$next_working_dir" "$next_input_profile" "$next_target_directory"
            done
    done