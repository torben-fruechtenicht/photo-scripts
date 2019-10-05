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
# - The input profile holds all settings which are independent of camera or lens, e.g. setting the RawTherapee version
#   header (that way profiles for different RawTherapee versions are possible) or having always all metadata copied into 
#   output files.
# - The contents of a baseline are melded into the given input profile, thus forming the output profile.
# - After processing a baseline, a check is performed if sub directories exist which also contain baselines.
# - This script is invoked again for each of these next baselines, now using the output profile which was created
#   in the current directory as the input profile.
#
# - Parameters
#   $1 working directory or path to a baseline
#   $2 input profile
#   $3 target directory (output profile is created there)

set -ue

declare -r SELF=$(readlink -e "$0")
declare -r MELD_BASELINE=$(dirname "$SELF")/meld_baseline.sh

while getopts "t:" opt; do
    case $opt in
        t )    
            declare -r FILE_TYPE=$OPTARG;;
    esac
done
shift $(($OPTIND - 1))

declare -r WORKING_DIR=$(readlink -e "$1")
if [[ -z "$WORKING_DIR" ]]; then
    echo "Missing working dir" >&2
    exit 1
fi
echo "[WORKING DIRECTORY] $WORKING_DIR" >&2

declare -r INPUT_PROFILE=$(readlink -e "$2")
if [[ -z "$INPUT_PROFILE" ]]; then
    echo "Missing input profile" >&2
    exit 1
fi
echo "[INPUT PROFILE] $INPUT_PROFILE" >&2

declare -r TARGET_DIR=$(readlink -f "$3")
if ! [[ -e $TARGET_DIR ]]; then
    echo "Creating missing target directory $3" >&2
    mkdir "$TARGET_DIR"
fi

if [[ -v FILE_TYPE ]]; then
    baselines_pattern='-name baseline.'$FILE_TYPE'.pp3'
else 
    baselines_pattern='-regex .*baseline\(..*\)?.pp3'
fi

find "$WORKING_DIR" -mindepth 1 -maxdepth 1 -type f $baselines_pattern |\
    while read baseline; do
        baseline_filename=$(basename "$baseline")
        echo "[BASELINE] $baseline" >&2
        target_profile=$TARGET_DIR/${baseline_filename/baseline/template}
        echo "[TARGET] $target_profile" >&2


        if ! [[ -e $target_profile ]]; then
            cp "$INPUT_PROFILE" "$target_profile"
            $MELD_BASELINE "$baseline" "$target_profile"
        else 
            echo "Target profile $target_profile exists, no overwriting" >&2
        fi


        # TODO if no baseline with matching filetype exists, try baseline.pp3        
        next_input_profile=$target_profile
        next_baseline_filetype_pattern=$(echo $baseline_filename | sed -n 's/baseline\(.*\).pp3/\1/p')
        find "$WORKING_DIR" -mindepth 2 -maxdepth 2 -name "baseline$next_baseline_filetype_pattern.pp3" |\
            while read next_baseline; do
                next_working_dir=$(dirname "$next_baseline")
                next_target_directory="$TARGET_DIR/${next_working_dir##*/}"
                $SELF "$next_working_dir" "$next_input_profile" "$next_target_directory"
            done
    done