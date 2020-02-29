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

print_album_burndown() {
    local -r album_stats_file=$1

    local -r album=$(basename "$album_stats_file" | cut -d'_' -f2)

    local -r current_incoming=$(current_count "incoming" "$album_stats_file")
    local -r previous_incoming_yesterday=$(previous_count "incoming" 1 "$album_stats_file")
    local -r previous_incoming_week=$(previous_count "incoming" 7 "$album_stats_file")
    local -r previous_incoming_month=$(previous_count "incoming" 30 "$album_stats_file")
    local -r previous_incoming_quarteryear=$(previous_count "incoming" 90 "$album_stats_file")
    

    local -r current_archive=$(current_count "archive" "$album_stats_file")
    local -r previous_archive_week=$(previous_count "archive" 7 "$album_stats_file")
    local -r previous_archive_month=$(previous_count "archive" 30 "$album_stats_file")
    local -r previous_archive_year=$(previous_count "archive" 90 "$album_stats_file")
    

    local -r previous_incoming="$(print_sep_by_slash $previous_incoming_yesterday $previous_incoming_week \
        $previous_incoming_month $previous_incoming_quarteryear)"
    local -r previous_archive="$(print_sep_by_slash $previous_archive_week $previous_archive_month $previous_archive_year)"
    echo "$album $current_incoming ($previous_incoming) / $current_archive ($previous_archive)"
}

# list all albums with recent changes, each sublist sorted by largest change (no matter if more or less)
# each sublist goes in separate variable to hold report. alternatively, echo each report at end of creation - but that is probably not
# possible since it might be best to traverse the full data in one go (and decide for each album/year combo in which reports it
# must go)

cd "$STATS_REPO" && find -type f | cut -d'_' -f 1 | sort -u -r |\
    while read -r year; do         
        year=$(basename "$year")
        echo $year
        find -type f -name "${year}_*" | sort |\
            while read -r stats_file; do
                # echo $stats_file >&2
                print_album_burndown "$stats_file"
            done
    done

# changed in last week

# changed in last month

# changed in last 3 montsh

# list all albums with full data

# list albums with no or invalid data

# TBD what about report at year level?