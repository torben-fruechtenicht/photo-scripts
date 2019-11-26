#! /usr/bin/env bash

set -e
shopt -s nocasematch

source "$(dirname "$(readlink -e $0)")/metadata.sh"

declare -r SOURCE_PHOTOS=$@

set -u

for sourcephoto in $SOURCE_PHOTOS; do

    sourcephoto=$(readlink -e "$sourcephoto")
    is_original_photofile "$sourcephoto" || continue
    
    sourcephoto_fullname=$(fullname_from_photofile "$sourcephoto")
    
    # Find all files, i.e. actual photo file and all associated files: search for the basename without
    # extensions in the directory of $sourcephoto and below. Move each file and rename if enabled
	find $(dirname "$sourcephoto") -type f -path "*/${sourcephoto_fullname}*"

done