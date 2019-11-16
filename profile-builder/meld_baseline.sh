#! /usr/bin/env bash

# Replaces or adds all entries from BASELINE in the correct sections in PROFILE (i.e. PROFILE is changed).
# PROFILE must already contain all sections with at least the header ("[section]").

set -ue

. "$(dirname "$(readlink -e "$0")")/sidecar.sh"

while getopts "v" opt; do
	case $opt in
		v )    
            declare -r VERBOSE=;;
	esac
done
shift $(($OPTIND - 1))

declare -r BASELINE=$(readlink -e "$1")
if [[ -z $BASELINE ]]; then
    echo "[ERROR] Missing baseline parameter or file" >&2
    exit 1
fi

declare -r PROFILE=$(readlink -e "$2")
if [[ -z $PROFILE ]]; then
    echo "[ERROR] Missing profile parameter or file" >&2
    exit 1
fi

cat "$BASELINE" | while read -r line; do
    # save the section header
    if [[ $line =~ \[.*\] ]]; then
        section=$(echo $line | tr -d '[' | tr -d ']')
        continue
    fi

    # end of section, switch to scanning for next section mode (i.e. section is not set)
    if [[ -z $line ]]; then
        section=
        continue
    fi

    # extra blank lines (actually, all unexpected lines) are skipped
    if [[ -z $section ]]; then
        continue
    fi

    # TODO handle comments 

    property=$(echo $line | cut -d'=' -f1)
    value=$(echo $line | cut -d'=' -f2)
    replace_in_sidecar "$PROFILE" "$section" "$property" "$value"
done