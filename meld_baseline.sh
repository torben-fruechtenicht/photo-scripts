#! /usr/bin/env bash

set -u

declare -r BASELINE=$(readlink -e "$1")
if [[ -z $BASELINE ]]; then
    echo "Missing baseline parameter" >&2
    exit 1
fi

declare -r PROFILE=$(readlink -e "$2")
if [[ -z $PROFILE ]]; then
    echo "Missing profile parameter" >&2
    exit 1
fi

replace_in_profile() {    
    local -r section=$1
    local -r property=$2
    local -r value=$3

    if sed -n '/\['"$section"'\]/,/^$/p' "$PROFILE" | grep -q "$property"; then
        # if the entry already exists, just overwrite with new value
        echo "Updating $2 with value $3" >&2        
        # https://unix.stackexchange.com/a/416126
        sed -ie  '/\['"$section"'\]/,/^$/s/'"$property"=.*$'/'"$property"'='"$value\n"'/' "$PROFILE"    
    else        
        # if the entry does not exist, append to end of section
        echo "Adding $2 with value $3" >&2
        sed -ie  '/\['"$section"'\]/,/^$/s/^$/'"$property"'='"$value\n"'/' "$PROFILE"
    fi
}

cat $BASELINE | while read -r line; do
    # save the section header
    if [[ $line =~ \[.*\] ]]; then
        section=$(echo $line | tr -d '[' | tr -d ']')
        echo "Section $section" >&2
        continue
    fi

    # end of section
    if [[ -z $line ]]; then
        echo "End of section $section" >&2
        section=
        continue
    fi

    # extra blank lines (actually, all unexpected lines) are skipped
    if [[ -z $section ]]; then
        echo "Skipping line: outside of section but no new section" >&2
        continue
    fi

    property=$(echo $line | cut -d'=' -f1)
    value=$(echo $line | cut -d'=' -f2)
    replace_in_profile "$section" "$property" "$value"

done