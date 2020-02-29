#! /usr/bin/env bash

set -e

source "$(dirname "$(readlink -e $0)")/burndown_stats_lib.sh"

declare -r ROOT_DIR=$(readlink -e "$1")
if [[ -z $ROOT_DIR ]]; then
    echo "[ERROR] No root dir given or dir does not exist" >&2
    exit 1
fi

declare -r SOURCE_TYPE=$2
if [[ -z SOURCE_TYPE ]] || ! [[ $SOURCE_TYPE =~ incoming|archive ]]; then
    echo "[ERROR] source type parameter missing${SOURCE_TYPE:+ or wrong type: $SOURCE_TYPE}" >&2
    exit 1
fi

declare -r STATS_REPO=$(readlink -f "$3")
if [[ -z $STATS_REPO ]]; then
    echo "[ERROR] No stats repo dir given" >&2
    exit 1
elif ! [[ -e $STATS_REPO ]]; then
    echo "[INFO] Creating stats repo dir $STATS_REPO" >&2
    mkdir "$STATS_REPO"
fi


cd "${ROOT_DIR}" && find . -mindepth 2 -maxdepth 2 -type d |\
    while read -r album_dir; do
        
        album=$(basename "$album_dir")
        year=$(basename "$(dirname "$album_dir")")

        stats_file="${STATS_REPO}/${year}_${album}"
        create_stats_file_if_missing "$stats_file"

        patterns="-iname *.ORF -o -iname *.RAW -o -iname *.CRW -o -iname *.CR2"
        current_value=$(find "$album_dir" -type f \( $patterns \) | wc -l)
        current_key="current_${SOURCE_TYPE}"        
        sed -i 's/'"$current_key"'=.*$/'"$current_key"'='"$current_value"'/' "$stats_file"

    done