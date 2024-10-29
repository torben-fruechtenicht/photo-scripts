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

rotate_previous_values() {

    local -r statsfile=$1
    local -r sourcetype=$2

    current_value=$(current_count $sourcetype "$statsfile")
    if [[ -n $current_value ]]; then

        # rotate all except first
        last_line_number=$(linenumber_of_last_previous_entry $sourcetype "$statsfile")
        for (( i=0; i<$(( $MAX_PREVIOUS - 1 )); i++ )); do 

            target_idx=$(($MAX_PREVIOUS - i )) 
            source_idx=$(($target_idx - 1 ))                    

            source_value=$(previous_count $sourcetype $source_idx "$statsfile" "")
            if [[ -z $source_value ]]; then
                # echo "[WARN] No value in previous_${sourcetype}_$source_idx, will not rotate it" >&2
                continue
            fi

            target_line_number=$(( $last_line_number - $i ))
            target_key="previous_${sourcetype}_$target_idx"
            sed_cmd_write_statsfile_entry "$target_key" "$source_value" $(( $target_line_number + 1 ))
            
        done

        # write previous-1
        previous_1_key="previous_${sourcetype}_1"
        sed_cmd_write_statsfile_entry "$previous_1_key" $current_value 

    else
        echo "[WARN] No current value for $sourcetype, will not rotate" >&2
    fi 
}

# putting this check into a function has the advantage that we don't have to reset any variables, all time
# values are scoped to the function
needs_rotation() {
    local -r statsfile=$1

    last_rotate_ts=$(read_statsfile_entry "$LAST_ROTATE_KEY" "$statsfile")
    # new rotation should be 24 hours after previous one but let's give another 30 mins buffer for subtle timestamp
    # variations
    new_rotate_begin=$(( $last_rotate_ts + 86400 - 1800 )) 
    now=$(date +%s)

    test -z $last_rotate_ts || (( $new_rotate_begin < $now ))
}

cd "$STATS_REPO" && find -type f | while read -r statsfile; do
        
    create_stats_file_if_missing "$statsfile"

    if needs_rotation "$statsfile"; then

        echo "[INFO] Rotating $statsfile" >&2

        sed_script=$(mktemp)

        rotate_previous_values "$statsfile" "incoming" >> "$sed_script"
        rotate_previous_values "$statsfile" "archive" >> "$sed_script"

        new_rotate_ts=$(date +%s)
        sed_cmd_write_statsfile_entry "$LAST_ROTATE_KEY" $new_rotate_ts >> "$sed_script"

        sed -i -f "$sed_script" "$statsfile" && rm "$sed_script"

    else 
        echo "[WARN] Last rotation was less then 24h ago, will not rotate" >&2
        continue
    fi  

done  

