#! /usr/bin/env bash

set -uex

PATH=$(dirname "$0"):$PATH

declare -r BASELINE_PP3=$(readlink -e "$1")
if [[ -z $BASELINE_PP3 ]]; then
    echo "Missing baseline" >&2
    exit 1
fi

declare -r INPUT_PROFILE=$(readlink -e "$2")
if [[ -z $INPUT_PROFILE ]]; then
    echo "Missing input profile" >&2
    exit 1
fi

declare -r OUTPUT_PROFILE=$(readlink -f "$3")
if [[ -z $OUTPUT_PROFILE ]]; then
    echo "Output profile path does not exist" >&2
    exit 1
fi
if [[ -e $OUTPUT_PROFILE ]]; then
    echo "Output profile $OUTPUT_PROFILE already exists"
    exit 1
fi

cp "$INPUT_PROFILE" "$OUTPUT_PROFILE"
meld_baseline.sh "$BASELINE_PP3" "$OUTPUT_PROFILE"

# find . -mindepth 1 -maxdepth 1 -name 'baseline.pp3' 

# TODO check if subdirectories exist which have a baseline file
# if yes call this script again with parameters for subdirectory
# FIXME instead of using INPUT_PROFILE from TEMPLATE_DIR, each call for a subdirectory
#   must be passed the profile which was created in the parent directory
# TBD then how do we handle the case for the first level? use INPUT_PROFILE if no 
#   profile was passed? or caller must pass INPUT_PROFILE to the initial invocation of
#   this script?



