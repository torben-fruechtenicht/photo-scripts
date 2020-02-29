#! /usr/bin/env bash

set -eu

source "$(dirname "$(readlink -e $0)")/burndown_stats_lib.sh"

declare -r ROOT_DIR=$(readlink -e "$1")
if [[ -z $ROOT_DIR ]]; then
    echo "[ERROR] No root dir given or dir does not exist" >&2
    exit 1
fi

# either incoming or archive
declare -r SOURCE_TYPE=$2

declare -r STATS_REPO=$(readlink -f "$3")
if [[ -z $STATS_REPO ]]; then
    echo "[ERROR] No stats repo dir given" >&2
    exit 1
elif ! [[ -e $STATS_REPO ]]; then
    echo "[INFO] Creating stats repo dir $STATS_REPO" >&2
    mkdir "$STATS_REPO"
fi

cd "${ROOT_DIR}" && find . -mindepth 2 -maxdepth 2 -type d -name "Amsterdam*"|\
    while read -r album_dir; do
        
        album=$(basename "$album_dir")
        year=$(basename "$(dirname "$album_dir")")

        stats_file="${STATS_REPO}/${year}_${album}"
        create_stats_file_if_missing "$stats_file"

        current_value=$(grep "current_$SOURCE_TYPE=*" "$stats_file" | cut -d '=' -f 2)
        last_rotate_key="last_rotate_$SOURCE_TYPE"

        if [[ -n $current_value ]]; then

            last_rotate=$(grep "$last_rotate_key=" "$stats_file" | cut -d '=' -f 2)
            new_rotate_begin=$(( $last_rotate + 86400 ))
            now=$(date +%s)

            # rotate all previous entries except the very first one (see condition in for loop)
            if [[ -z $last_rotate ]] || (( $new_rotate_begin < $now )); then
                echo "$stats_file"

                # rotate all except first
                last_line_number=$(grep -n "previous_${SOURCE_TYPE}_${MAX_PREVIOUS}" "$stats_file" | cut -d : -f 1)
                for (( i=0; i<$(( $MAX_PREVIOUS - 1 )); i++ )); do 

                    target_idx=$(($MAX_PREVIOUS - i )) 
                    source_idx=$(($target_idx - 1 ))                    

                    source_value=$(grep "previous_${SOURCE_TYPE}_$source_idx=" "$stats_file" | cut -d '=' -f 2)
                    if [[ -z $source_value ]]; then
                        echo "[WARN] No value in previous_${SOURCE_TYPE}_$source_idx, will not rotate it" >&2
                        continue
                    fi

                    target_line_number=$(( $last_line_number - $i ))
                    target_key="previous_${SOURCE_TYPE}_$target_idx"
                    sed -i ''"$target_line_number"'s/.*/'"$target_key"'='"$source_value"'/' "$stats_file"
                    
                done

                # write previous-1
                previous_1_key="previous_${SOURCE_TYPE}_1"
                sed -i 's/'"$previous_1_key"'=.*$/'"$previous_1_key"'='"$current_value"'/' "$stats_file"

                # write last_rotate
                sed -i 's/'"$last_rotate_key"'=.*$/'"$last_rotate_key"'='"$(date +%s)"'/' "$stats_file"

            else 
                echo "[WARN] Last rotation was less then 24h ago, will not rotate" >&2
            fi

        else
            echo "[WARN] No current value, will not rotate" >&2
        fi       

    done

