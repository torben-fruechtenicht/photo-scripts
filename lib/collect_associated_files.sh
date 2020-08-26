#! /usr/bin/env bash

set -eu
shopt -s nocasematch

declare -r BASE_DIR="$(dirname "$(readlink -e "$0")")/.."
source "$BASE_DIR/lib/photofiles.sh"

PATH="$BASE_DIR/lib:$PATH"

if (( $# == 0 )); then
    declare -r READ_PHOTOS_FROM_STDIN=
else 
    declare -r PHOTOS=$@
fi


print_associated_files() {
    local -r photo=$1

    is_original_photofile "$photo" || return

    local -r photo_filename=$(basename "$photo")
    local -r sourcephoto_fullname=${photo_filename%%.*}
    # Find all files, i.e. actual photo file and all associated files: search for the basename without
    # extensions in the directory of $photo and below. 
    find $(dirname "$photo") -type f -path "*/${sourcephoto_fullname}*"
}

if [[ -v READ_PHOTOS_FROM_STDIN ]]; then
    while read -r photo; do 
        print_associated_files "$(readlink -e "$photo")" | sort
    done < /dev/stdin
else 
    for photo in $PHOTOS; do
        print_associated_files "$(readlink -e "$photo")" | sort
    done
fi 