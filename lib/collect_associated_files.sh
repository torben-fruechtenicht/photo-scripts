#! /usr/bin/env bash

set -e
shopt -s nocasematch

source "$(dirname "$(readlink -e $0)")/metadata.sh"

declare -r SOURCE_PHOTOS=$@

set -u

for sourcephoto in $SOURCE_PHOTOS; do

    sourcephoto=$(readlink -e "$sourcephoto")

    if ! [[ -e $sourcephoto ]]; then
        echo "[SKIP] $sourcephoto does not exist" >&2
        continue
    fi

    # skip directories and all non-photo files, e.g. sidecars
    if ! [[ $sourcephoto =~ .+\.(ORF|RAW|JPG|CRW|CR2)$ && -f $sourcephoto ]]; then
		echo "[SKIP] $sourcephoto is not a photo" >&2
		continue
	fi
    
    # TBD really skip any source photos from a converted dir?
    # TBD what would happen if sourcephoto is an output file?
    # TBD what to do with a file from a converted dir? only move the file? or collect
    # all other files incl original and move all?
    if [[ $sourcephoto =~ .+/converted/^/+$ ]]; then
        echo "[SKIP] $sourcephoto is an output file, only originals accepted" >&2
        continue
    fi

    # FIXME check that parent directories of sourcephoto are year/album/date

    sourcephoto_fullname=$(fullname_from_photofile "$sourcephoto")
    
    # Find all files, i.e. actual photo file and all associated files: search for the basename without
    # extensions in the directory of $sourcephoto and below. Move each file and rename if enabled
	find $(dirname "$sourcephoto") -type f -path "*/${sourcephoto_fullname}*"

done