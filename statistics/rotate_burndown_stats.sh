#! /usr/bin/env bash

set -eu

source "$(dirname "$(readlink -e $0)")/burndown_stats_lib.sh"

declare -r ROOT_DIR=$(readlink -e "$1")
if [[ -z $ROOT_DIR ]]; then
    echo "[ERROR] No root dir given or dir does not exist" >&2
    exit 1
fi

declare -r STATS_REPO=$(readlink -f "$2")
if [[ -z $STATS_REPO ]]; then
    echo "[ERROR] No stats repo dir given" >&2
    exit 1
elif ! [[ -e $STATS_REPO ]]; then
    echo "[INFO] Creating stats repo dir $STATS_REPO" >&2
    mkdir "$STATS_REPO"
fi

rotate_if_needed() {

    local -r stats_file=$1
    local -r source_type=$2

    current_value=$(grep "current_$source_type=*" "$stats_file" | cut -d '=' -f 2)
    if [[ -n $current_value ]]; then

        # rotate all except first
        last_line_number=$(grep -n "previous_${source_type}_${MAX_PREVIOUS}" "$stats_file" | cut -d : -f 1)
        for (( i=0; i<$(( $MAX_PREVIOUS - 1 )); i++ )); do 

            target_idx=$(($MAX_PREVIOUS - i )) 
            source_idx=$(($target_idx - 1 ))                    

            source_value=$(grep "previous_${source_type}_$source_idx=" "$stats_file" | cut -d '=' -f 2)
            if [[ -z $source_value ]]; then
                echo "[WARN] No value in previous_${source_type}_$source_idx, will not rotate it" >&2
                continue
            fi

            target_line_number=$(( $last_line_number - $i ))
            target_key="previous_${source_type}_$target_idx"
            sed -i ''"$target_line_number"'s/.*/'"$target_key"'='"$source_value"'/' "$stats_file"
            
        done

        # write previous-1
        previous_1_key="previous_${source_type}_1"
        sed -i 's/'"$previous_1_key"'=.*$/'"$previous_1_key"'='"$current_value"'/' "$stats_file"

    else
        echo "[WARN] No current value for $source_type, will not rotate" >&2
    fi 
}

cd "${ROOT_DIR}" && find . -mindepth 2 -maxdepth 2 -type d -name "Amsterdam*"|\
    while read -r album_dir; do
        
        album=$(basename "$album_dir")
        year=$(basename "$(dirname "$album_dir")")

        stats_file="${STATS_REPO}/${year}_${album}"
        create_stats_file_if_missing "$stats_file"

        last_rotate_key="last_rotate"
        last_rotate=$(grep "last_rotate=" "$stats_file" | cut -d '=' -f 2)
        new_rotate_begin=$(( $last_rotate + 86400 ))
        now=$(date +%s)

        if [[ -z $last_rotate ]] || (( $new_rotate_begin < $now )); then

            echo "$stats_file"
            rotate_if_needed "$stats_file" "incoming"
            rotate_if_needed "$stats_file" "archive"
            sed -i 's/'"$last_rotate_key"'=.*$/'"$last_rotate_key"'='"$(date +%s)"'/' "$stats_file"

        else 
            echo "[WARN] Last rotation was less then 24h ago, will not rotate" >&2
        fi  

    done  

