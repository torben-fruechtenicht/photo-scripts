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

print_sep_by_slash() {
    local IFS="/"
    echo "$*"
}

print_numbers() {
    local -r source_type=$1
    local -r intervals=$2
    local -r album_stats_file=$3

    local -r current_value=$(current_count $source_type "$album_stats_file")
    local -r previous_values=$(print_sep_by_slash $(
        for interv in $intervals; do
            echo $(previous_count $source_type $interv "$album_stats_file")
        done
    ))

    echo "$current_value ($previous_values)"
}

# list all albums with recent changes, each sublist sorted by largest change (no matter if more or less)
# each sublist goes in separate variable to hold report. alternatively, echo each report at end of creation - but that is probably not
# possible since it might be best to traverse the full data in one go (and decide for each album/year combo in which reports it
# must go)

cd "$STATS_REPO" && find -type f | cut -d'_' -f 1 | sort -u -r |\
    while read -r year; do      

        year=$(basename "$year")

        echo $year
        echo "===="

        # TODO print total count of year

        find -type f -name "${year}_*" | sort |\
            while read -r stats_file; do
                echo "$(basename "$stats_file" | cut -d'_' -f2)"                
                echo "incoming: $(print_numbers "incoming" "1 7 30 90" "$stats_file")"
                echo "archived: $(print_numbers "archive" "7 30 90" "$stats_file")"
                echo
            done
        echo
    done

# changed in last week

# changed in last month

# changed in last 3 montsh

# list albums with no or invalid data

# TBD what about report at year level?