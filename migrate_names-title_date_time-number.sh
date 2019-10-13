#! /usr/bin/env bash

while getopts "t:" opt; do
    case $opt in
        t )    
            declare -r NEW_TITLE=$OPTARG;;
    esac
done
shift $(($OPTIND - 1))

declare -r CAMERA=$1
shift 1

for file in $*; do 
    if [[ -d $file ]]; then
        continue
    fi

    if [[ -v NEW_TITLE ]]; then
        title=$NEW_TITLE
    else
        title="\1"
    fi

    # ([^_]+)
    # ([0-9]{8})
    # ([0-9]{4})
    # ([0-9]{6}(-[a-ZA-Z0-9-]+)?)
    # ([a-ZA-Z0-9]{3})
    new_name=$(echo "$(basename "$file")" | \
        sed -r 's/([^_]+)_([0-9]{8})_([0-9]{4})-([0-9]{6}(-[a-ZA-Z0-9-]+)?)\.([a-ZA-Z0-9]{3})/'"$title"'_\2_\3_'"$CAMERA"'_\4.\6/')
    target_file="$(dirname "$file")/$new_name"
    if [[ -e $target_file ]]; then
        echo "$target_file exists" >&2
        continue
    fi
    mv --no-clobber "$file" "$target_file"
done