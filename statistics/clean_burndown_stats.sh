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

has_only_zero_entries() {
    local -r file=$1
    local -r nonzero_lines_count=$(grep 'current_\|previous_' "$file" | grep -c -v '=0$')
    (( $nonzero_lines_count == 0 ))
}

cd "$STATS_REPO" && find -type f | while read -r statsfile; do

    # or use all entries have the same value? that would mean there hasn't been an update for the last
    # 365 days which is pretty obvious...
    # NB if deletion should not have happened: does not matter because stats file will be created anew
    # on next run of update script?
    # TBD why don't we not really delete but only move the files into a stale stats folder? and if the
    # update script again has data, it can recreate the statsfile from the stale one
    if has_only_zero_entries $statsfile; then
        echo "[INFO] Deleting $statsfile, has only zero value entries"
        #rm $statsfile
    fi

done