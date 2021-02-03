#! /usr/bin/env bash

set -eu

source "$(dirname "$(readlink -e $0)")/burndown_stats_lib.sh"

declare -r STATS_REPO=$(readlink -f "$1")
if [[ -z $STATS_REPO ]]; then
    echo "[ERROR] No stats repo dir given" >&2
    exit 1
elif ! [[ -e $STATS_REPO ]]; then
    echo "[ERROR] stats repo dir $STATS_REPO does not exist" >&2
    exit 1
elif [[ -n $(find "$STATS_REPO" -type d -prune -empty) ]]; then
    echo "[ERROR] no stats files in $STATS_REPO" >&2
    exit 1
fi

print_sep_by_slash() {
    local IFS="/"
    echo "$*"
}

print_numbers() {
    local -r sourcetype=$1
    local -r intervals=$2
    local -r album_stats_file=$3

    local -r current_value=$(current_count $sourcetype "$album_stats_file")
    local -r previous_values=$(print_sep_by_slash $(
        for interv in $intervals; do
            echo $(previous_count $sourcetype $interv "$album_stats_file" "-")
        done
    ))

    echo "values $album_stats_file: $current_value $previous_values" >&2

    if ! [[ $current_value = 0 ]] && ! [[ $previous_values =~ ^0(/0)*$ ]]; then
        echo "$current_value ($previous_values)"
    fi
}

print_album_stats() {
    local -r statsfile=$1

    local -r incoming_stats=$(print_numbers "incoming" "1 7 30 90" "$statsfile")
    local -r archived_stats=$(print_numbers "archive" "7 30 90" "$statsfile")

    if [[ -z $incoming_stats ]] && [[ -z $archived_stats ]]; then
        return
    fi

    echo "$(basename "$statsfile" | cut -d'_' -f2)"                
    if [[ -n $incoming_stats ]]; then
        echo "incoming: $incoming_stats"
    fi

    if [[ -n $archived_stats ]]; then
        echo "archived: $archived_stats"
    fi
}

collect_current_counts() {
    local -r pattern=$1
    local -r sourcetype=$2
    grep "current_$sourcetype=" $STATS_REPO/$pattern | cut -d'=' -f 2
}

count_photos() {
    local -r pattern=$1
    local -r sourcetype=$2
    local count=0

    for i in $(collect_current_counts "$pattern" $sourcetype); do
        count=$(( $count + i ))
    done

    echo $count
}

changed_since_days() {
    local -r interval=$1
    local -r sourcetype=$2
    local -r statsfile=$3

    local -r currentvalue=$(current_count $sourcetype "$statsfile")
    local -r previousvalue=$(previous_count $sourcetype $interval "$statsfile" 0)

    ! test $currentvalue -eq $previousvalue
}

# list all albums with recent changes, each sublist sorted by largest change (no matter if more or less)
# each sublist goes in separate variable to hold report. alternatively, echo each report at end of creation - but that is probably not
# possible since it might be best to traverse the full data in one go (and decide for each album/year combo in which reports it
# must go)

echo "Burndown report"
echo "==============="

echo "grand total $(count_photos "*" "incoming") / $(count_photos "*" "archive")"
echo

cd "$STATS_REPO" && find -type f | cut -d'_' -f 1 | sort -u -r | while read -r year; do      

    year=$(basename "$year")

    echo $year
    echo "===="

    echo "total $(count_photos "${year}_*" "incoming") / $(count_photos "${year}_*" "archive")"
    echo

    find -type f -name "${year}_*" | sort |\
        while read -r statsfile; do
            album_stats=$(print_album_stats "$statsfile")
            if [[ -n $album_stats ]]; then
                echo "$album_stats"
                echo
            fi
            # if changed_since_days 7 incoming "$statsfile"; then
            #     echo "changed last 7 days" >&2
            # fi
        done
    echo
done

# changed in last week, sorted by album with largest change

# changed in last month, sorted by album with largest change

# changed in last 3 months, , sorted by album with largest change

# list albums with no or invalid data

# TBD what about report at year or month level?
# NB both added and done photos must be taken care of, i.e. add or substract from count

# TODO if report should be rendered as markup (e.g. HTML):
# output only at album/year granularity in a format readable by rendering script
# format idea: year_album_valuekey=value where "valuekey" is current|previous_