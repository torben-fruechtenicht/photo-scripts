#! /usr/bin/env bash

set -ue

while getopts "v" opt; do
	case $opt in
		v )    
            declare -r VERBOSE=;;
	esac
done
shift $(($OPTIND - 1))

declare -r BASELINE=$(readlink -e "$1")
if [[ -z $BASELINE ]]; then
    echo "Missing baseline parameter or file" >&2
    exit 1
fi

declare -r PROFILE=$(readlink -e "$2")
if [[ -z $PROFILE ]]; then
    echo "Missing profile parameter or file" >&2
    exit 1
fi

replace_in_profile() {    
    local -r section=$1
    local -r property=$2
    local -r value=$3

    if sed -n '/\['"$section"'\]/,/^$/p' "$PROFILE" | grep -q "$property"; then
        # if the entry already exists, just overwrite with new value
        test -v VERBOSE && echo "Updating $2 with value $3" >&2        
        # https://unix.stackexchange.com/a/416126
        sed -i  '/\['"$section"'\]/,/^$/s/'"$property"=.*$'/'"$property"'='"$value\n"'/' "$PROFILE"    
    else        
        # if the entry does not exist, append to end of section
        test -v VERBOSE && echo "Adding $2 with value $3" >&2
        sed -i  '/\['"$section"'\]/,/^$/s/^$/'"$property"'='"$value\n"'/' "$PROFILE"
    fi
}

cat $BASELINE | while read -r line; do
    # save the section header
    if [[ $line =~ \[.*\] ]]; then
        section=$(echo $line | tr -d '[' | tr -d ']')
        test -v VERBOSE && echo "Section $section" >&2
        continue
    fi

    # end of section
    if [[ -z $line ]]; then
        test -v VERBOSE && echo "End of section $section" >&2
        section=
        continue
    fi

    # extra blank lines (actually, all unexpected lines) are skipped
    if [[ -z $section ]]; then
        test -v VERBOSE && echo "Skipping line: outside of section but no new section" >&2
        continue
    fi

    # TODO handle comments 

    property=$(echo $line | cut -d'=' -f1)
    value=$(echo $line | cut -d'=' -f2)
    replace_in_profile "$section" "$property" "$value"

done