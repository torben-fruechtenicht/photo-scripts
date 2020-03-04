#! /usr/bin/env bash

set -eu

source "$(dirname "$(readlink -e $0)")/burndown_stats_lib.sh"

declare -r STATS_REPO=$(readlink -f "$1")
if [[ -z $STATS_REPO ]]; then
    echo "[ERROR] No stats repo dir given" >&2
    exit 1
elif ! [[ -e $STATS_REPO ]]; then
    echo "[INFO] Creating stats repo dir $STATS_REPO" >&2
    mkdir "$STATS_REPO"
fi

declare -r LAST_ROTATE_KEY="last_rotate"

linenumber_of_last_previous_entry() {
    grep -n -m 1 "previous_${1}_${MAX_PREVIOUS}" "$2" | cut -d : -f 1        
}

rotate_if_needed() {

    local -r statsfile=$1
    local -r sourcetype=$2

    current_value=$(current_count $sourcetype "$statsfile")
    if [[ -n $current_value ]]; then

        # rotate all except first
        last_line_number=$(linenumber_of_last_previous_entry $sourcetype "$statsfile")
        for (( i=0; i<$(( $MAX_PREVIOUS - 1 )); i++ )); do 

            target_idx=$(($MAX_PREVIOUS - i )) 
            source_idx=$(($target_idx - 1 ))                    

            source_value=$(previous_count $sourcetype $source_idx "$statsfile")
            if [[ -z $source_value ]]; then
                # echo "[WARN] No value in previous_${sourcetype}_$source_idx, will not rotate it" >&2
                continue
            fi

            target_line_number=$(( $last_line_number - $i ))
            target_key="previous_${sourcetype}_$target_idx"
            write_statsfile_entry "$target_key" "$source_value" "$statsfile" $(( $target_line_number + 1 ))
            
        done

        # write previous-1
        previous_1_key="previous_${sourcetype}_1"
        write_statsfile_entry "$previous_1_key" $current_value "$statsfile"

    else
        echo "[WARN] No current value for $sourcetype, will not rotate" >&2
    fi 
}

cd "$STATS_REPO" && find -type f | while read -r statsfile; do
        
    create_stats_file_if_missing "$statsfile"

    last_rotate_ts=$(value_from_stats_file "$LAST_ROTATE_KEY" "$statsfile")
    new_rotate_begin=$(( $last_rotate_ts + 86400 ))
    now=$(date +%s)

    if [[ -z $last_rotate_ts ]] || (( $new_rotate_begin < $now )); then

        echo "[INFO] Rotating $statsfile" >&2

        rotate_if_needed "$statsfile" "incoming"
        rotate_if_needed "$statsfile" "archive"

        new_rotate_ts=$(date +%s)
        write_statsfile_entry "$LAST_ROTATE_KEY" $new_rotate_ts "$statsfile"

    else 
        echo "[WARN] Last rotation was less then 24h ago, will not rotate" >&2
    fi  

done  

