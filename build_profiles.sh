#! /usr/bin/env bash

# HOWTO
# =====
#
# - Walks a directory structure of baseline files and creates profiles by melding a baseline and an input profile.
# - Typically, the top level directory holds the camera baselines and sub directories exist for different lenses.
# - Baseline files are either generic ("baseline.pp3") or targeted at a specific photo filetype, e.g. 
#   - "baseline.jpg.pp3" for JPEGs
#   - "baseline.orf.pp3" for Olympus RAW files
#   (Normally, there should be no more than two filetypes, one for out of camera JPEGs and one for the camera's RAW
#   format.)
# - The contents of a baseline are melded into the given input profile, thus forming the output profile.
# - After processing a baseline, a check is performed if sub directories exist which also contain baselines.
# - This script is invoked again for each of these next baselines, now using the output profile which was created
#   in the current directory as the input profile.

set -ue

declare -r SELF=$(readlink -e "$0")
declare -r MELD_BASELINE=$(dirname "$SELF")/meld_baseline.sh

declare -r WORKING_DIR=$(readlink -e "$1")
if [[ -z "$WORKING_DIR" ]]; then
    echo "Missing working dir" >&2
    exit 1
fi
echo "Working dir: $WORKING_DIR" >&2

declare -r INPUT_PROFILE=$(readlink -e "$2")
if [[ -z "$INPUT_PROFILE" ]]; then
    echo "Missing input profile" >&2
    exit 1
fi
echo "Input profile: $INPUT_PROFILE" >&2

if [[ -z $(readlink -e "$3") ]]; then
    echo "Creating missing target directory $(readlink -f "$3")" >&2
    mkdir "$(readlink -f "$3")"
fi
declare -r TARGET_DIR=$(readlink -e "$3")

find "$WORKING_DIR" -mindepth 1 -maxdepth 1 -type f -regex '.*baseline\(..*\)?.pp3' |\
    while read baseline; do
        baseline_filename=$(basename "$baseline")
        echo "Baseline: $baseline" >&2
        output_profile=$TARGET_DIR/${baseline_filename/baseline/template}
        echo "Output profile: $output_profile" >&2
        # TODO check if output profile exists - exit if yes? only skip? skip but recurse?

        # step 1: create the output profile for the current baseline
        cp "$INPUT_PROFILE" "$output_profile"
        $MELD_BASELINE "$baseline" "$output_profile"

        # step 2: descend into subdirectories which have baselines for same filetype
        next_input_profile=$output_profile
        find "$WORKING_DIR" -mindepth 2 -maxdepth 2 -name "$baseline_filename" |\
            while read next_baseline; do
                next_working_dir=$(dirname "$next_baseline")
                next_target_directory="$TARGET_DIR/${next_working_dir##*/}"
                $SELF "$next_working_dir" "$next_input_profile" "$next_target_directory"
            done
    done