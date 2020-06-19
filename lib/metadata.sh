declare -r TITLE_PATTERN="([^_]+)" # \1
declare -r DATE_PATTERN="([0-9]{8})" # \2
declare -r TIME_PATTERN="([0-9]{4})" # \3
declare -r CAMERA_PATTERN="([a-zA-Z0-9-]+)" # \4
declare -r NUMBER_PATTERN="([0-9A-Z]+(-[a-zA-Z0-9-]+)?)" # \5
declare -r FILE_EXT_PATTERN="([a-ZA-Z0-9]{3})" # \6

declare -r PHOTO_FULLNAME_PATTERN="${TITLE_PATTERN}_${DATE_PATTERN}_${TIME_PATTERN}_${CAMERA_PATTERN}_${NUMBER_PATTERN}"

declare -r PHOTO_FILENAME_PATTERN="${PHOTO_FULLNAME_PATTERN}\.${FILE_EXT_PATTERN}"

fullname_from_photofile() {
    local -r photo_filename=$(basename "$1")
    echo "${photo_filename%%.*}"
}

headline_from_photofile() {
    local -r fullname=$(fullname_from_photofile "$1")
    echo "$fullname" | sed -r 's/'"$PHOTO_FULLNAME_PATTERN"'/\1 \5/'
}

is_original_photofile() ( 
# use "()" instead of "{}" so that the function body is executed as a subshell (shopt call can not
# interfere with the calling script)
    local -r file=$1
    shopt -s nocasematch

    # TODO check that parent directories of sourcephoto are year/album/date (or move to is_valid function)

    [[ -f $file ]] && \
        # TODO use PHOTO_FULLNAME_PATTERN
        [[ $file =~ .+\.(ORF|RAW|JPG|CRW|CR2)$ ]] && \
        ! [[ $file =~ .+/converted/^/+$ ]]
)
