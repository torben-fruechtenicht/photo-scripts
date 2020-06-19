#! /usr/bin/env bash

set -eu
shopt -s nocasematch

declare -r BASE_DIR="$(dirname "$(readlink -e "$0")")/.."
source "$BASE_DIR/lib/metadata.sh"
source "$BASE_DIR/lib/sidecar.sh"
source "$BASE_DIR/lib/jpeg.sh"

print_help() {
    cat <<EOF
Usage:
    $(basename "$0") [-v] [-s] [-h] [-r NEW_NAME] [-m RENAME_MODE] -t TARGET_DIRECTORY_ROOT PHOTO_FILES...

    PHOTO_FILES..
        A list of photo files (any non-image files are skipped), to be exact: the original files as saved 
        from the camera.
    -t TARGET_DIRECTORY_ROOT
        Path of the target directory, mandatory. See below for expected format
    -r NEW_NAME
        Change name of target files and album directories to NEW_NAME. Besides renaming files metadata pertaining
        to the name is changed, too. See also -R
    -m RENAME_MODE
        Valid values are "a" (rename only albums), "p" (rename only photos), "b" (rename both albums and photos)
        The default mode (if "-R" is not given) is "b".
    -v
        Verbose logging, print full path of each moved file to error out
    -s
        Simulate only, no files are moved or renamed/changed
    -h 
        Print help page

    General purpose command for moving photos to another directory. 
    For each given photo files, all associated files (output, variants, sidecar files) are moved alongside 
    the actual photo file. 
    Assumes that photos are from a year/album/dateTaken directory structure which is retained when moved. TARGET_DIRECTORY_ROOT is the
    root directory of this structure.
    In non-verbose mode (i.e. no "-v"), prints the path of each target file to standard out.

    Usecases:
        - renaming files: move_photos.sh -t <TARGET_DIR> -r <NEW_NAME> -R "p" <PHOTOS>
        - archiving files: move_photos.sh -t <ARCHIVE_DIR> <PHOTOS>
        - moving files to a different album: move_photos.sh -t <TARGET_DIR> -r <TARGET_ALBUM> -R a <PHOTOS> 
EOF
}


while getopts ":vshr:m:t:" opt; do
    case $opt in
        r ) 
            declare -r RENAME=${OPTARG};;   
        m ) 
            declare -r RENAME_MODE=$OPTARG;;
        v ) 
            declare -r VERBOSE=;;
        t )
            declare -r TARGET_DIRECTORY_ROOT=$(readlink -m "${OPTARG}")
            if [[ -z $TARGET_DIRECTORY_ROOT || ! -d $TARGET_DIRECTORY_ROOT ]]; then
                echo "[ERROR] target directory $OPTARG does not exist" >&2
                print_help
	            exit 1
            fi;;
        s ) 
            echo "[SIMULATE ONLY]" >&2
            declare -r SIMULATE=;;
        \? | h | *)
            print_help; exit;;
	esac
done
shift $(expr $OPTIND - 1)


declare -r SOURCE_PHOTOS=$@


if [[ ! -v TARGET_DIRECTORY_ROOT && -v RENAME ]]; then
    declare -r TARGET_DIRECTORY_ROOT=
elif [[ ! -v TARGET_DIRECTORY_ROOT && ! -v RENAME ]]; then
    echo "[ERROR] target directory missing" >&2
    print_help
	exit 1
fi


if [[ -v RENAME && ! -v RENAME_MODE ]]; then
    declare -r RENAME_MODE=b
fi

if [[ -v RENAME && ($RENAME_MODE == 'p' || $RENAME_MODE == 'b') ]]; then
    declare -r RENAME_PHOTOS=
fi

if [[ -v RENAME && ($RENAME_MODE == 'a' || $RENAME_MODE == 'b') ]]; then
    declare -r RENAME_ALBUMS=
fi



# Print the path of a file or directory (the child) relative to an ancestor directory. 
# For a directory, the relative path ends with an "/".
# FIXME which corner cases are covered?
# $1 - the parent directory
# $2 - a child of parent
# 
# Copied from http://stackoverflow.com/a/7892650
path_relative_to_ancestor() {
    local -r PARENT=$(readlink -f ${1})
    local -r CHILD=$(readlink -f ${2})

    local -r OLDIFS=$IFS
    IFS="/"

    local -r PARENT_ARRAY=($PARENT)
    local -r PARENT_ARRAY_LENGTH=$(echo ${PARENT_ARRAY[@]} | wc -w)

    local -r CHILD_ARRAY=($CHILD)
    local -r CHILD_ARRAY_LENGTH=$(echo ${CHILD_ARRAY[@]} | wc -w)

    local length=0
    test $PARENT_ARRAY_LENGTH -gt $CHILD_ARRAY_LENGTH && length=$PARENT_ARRAY_LENGTH || length=$CHILD_ARRAY_LENGTH

    local relative_path=""
    local append_to_end=""

    IFS=$OLDIFS
    # disable variable checking because the following loop depends on this
    set +u

    for (( i = 0; i <= $length + 1 ; i++ ))
    do
            if [[ "${PARENT_ARRAY[$i]}" = "${CHILD_ARRAY[$i]}" ]]; then
                continue    
            elif [[ "${PARENT_ARRAY[$i]}" != "" ]] && [[ "${CHILD_ARRAY[$i]}" != "" ]]; then
                append_to_end="${append_to_end}${CHILD_ARRAY[${i}]}/"
                relative_path="${relative_path}../"               
            elif [[ "${PARENT_ARRAY[$i]}" = "" ]]; then
                relative_path="${relative_path}${CHILD_ARRAY[${i}]}/"
            else
                relative_path="${relative_path}../"
            fi
    done

    relative_path="${relative_path}${append_to_end}"

    if ! [[ -d $CHILD ]]; then
        relative_path=${relative_path%/}
    fi

    echo $relative_path
}


photos_rootdir_from_photofile() {
    local -r file=$1
    local parent_basename=$(basename "$(dirname "$file")")
    # check for files from converted dir is actually not needed because we're skipping these
    # files anyway
    if [[ $parent_basename == "converted" ]]; then
        dirname "$(dirname "$(dirname "$(dirname "$(dirname "$file")")")")"
    else 
        dirname "$(dirname "$(dirname "$(dirname "$file")")")"
    fi
}


target_basename_from_sourcefile() {
    local -r sourcefile=$1
    if (( $# == 2 )); then
        local -r rename_to=$2
        basename "$sourcefile" | sed -e 's/[a-zA-Z0-9ßäÄöÖüÜ-]\+\(_.*\)/'"$rename_to"'\1/'
    else
        basename "$sourcefile"
    fi
}


target_relativepath_from_sourcefile() {
    local -r sourcefile=$1
    local -r sources_rootdir=$2

    if [[ $# == 3 ]]; then
        local -r new_album_name=$3
        dirname "$(path_relative_to_ancestor "$sources_rootdir" "$sourcefile")" |\
            sed -e 's|\([0-9]\+\)/[^/]*/\(.*\)|\1/'"${new_album_name}"'/\2|'
    else
        dirname "$(path_relative_to_ancestor "$sources_rootdir" "$sourcefile")"
    fi
}


targetfile_from_sourcefile() {
    
    local -r sourcefile=$1
    local -r sources_rootdir=$2


    if [[ -v RENAME_PHOTOS ]]; then
        local -r target_basename=$(target_basename_from_sourcefile "$sourcefile" "$RENAME")
    else 
        local -r target_basename=$(target_basename_from_sourcefile "$sourcefile")
    fi

    if [[ -v RENAME_ALBUMS ]]; then
        local -r target_relativepath=$(target_relativepath_from_sourcefile "$sourcefile" "$sources_rootdir" "$RENAME")
    else 
        local -r target_relativepath=$(target_relativepath_from_sourcefile "$sourcefile" "$sources_rootdir" )
    fi    


    if [[ -n $TARGET_DIRECTORY_ROOT ]]; then
        local -r target_directory_root=$TARGET_DIRECTORY_ROOT
    else 
        local -r target_directory_root=$sources_rootdir
    fi

    
    echo "${target_directory_root}/${target_relativepath}/${target_basename}"    
}



for sourcephoto in $SOURCE_PHOTOS; do

    sourcephoto=$(readlink -e "$sourcephoto")
    is_original_photofile "$sourcephoto" || continue

    sourcephoto_fullname=$(fullname_from_photofile "$sourcephoto")
    sources_rootdir=$(photos_rootdir_from_photofile "$sourcephoto")  
    
    # Find all files, i.e. actual photo file and all associated files: search for the basename without
    # extensions in the directory of $sourcephoto and below. Move each file and rename if enabled
	find $(dirname "$sourcephoto") -type f -path "*/${sourcephoto_fullname}*" | while read -r file_to_move; do        
    
        targetfile=$(targetfile_from_sourcefile "$file_to_move" "$sources_rootdir")
        if [[ -e "$targetfile" ]]; then
            echo "[SKIP] $targetfile exists" >&2
            continue
        fi

        if ! [[ -e $(dirname "$targetfile") ]]; then
            test -v SIMULATE || mkdir --parents "$(dirname "$targetfile")"
        fi

        test -v SIMULATE || mv -u "$file_to_move" "$targetfile"

        if [[ -v RENAME_PHOTOS ]]; then

            iptc_headline=$(headline_from_photofile "$targetfile")
            iptc_caption=$(fullname_from_photofile "$targetfile")            
            
            if ! [[ -w $targetfile ]]; then
                test -v SIMULATE || chmod u+w "$targetfile"
                declare restore_write_protection=
            fi

            if [[ $file_to_move =~ .*\.pp[23]$ ]]; then

                if ! [[ -v SIMULATE ]]; then
                    sidecar_set_property "$targetfile" "IPTC" "Headline" "$iptc_headline"
                    sidecar_set_property "$targetfile" "IPTC" "Caption" "[$iptc_caption]"
                fi

            elif [[ $file_to_move =~ .*/converted/.*\.jpg$ ]]; then

                if ! [[ -v SIMULATE ]]; then
                    jpeg_set_iptc "Headline" "$iptc_headline" "$targetfile"
                    jpeg_set_iptc "Caption" "[$iptc_caption]" "$targetfile"
                fi

            fi

            test -v restore_write_protection && \
                test -v SIMULATE || chmod u-w "$targetfile" && unset restore_write_protection
        fi   

        test -v VERBOSE && echo "[INFO] $file_to_move $targetfile" >&2
        echo "$targetfile"

    done # END OF INDIVIDUAL FILES LOOP
    
done # END OF SOURCE PHOTOS LOOP
