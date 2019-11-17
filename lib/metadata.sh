declare -r TITLE_PATTERN="([^_]+)" # \1
declare -r DATE_PATTERN="([0-9]{8})" # \2
declare -r TIME_PATTERN="([0-9]{4})" # \3
declare -r CAMERA_PATTERN="([a-zA-Z0-9-]+)" # \4
declare -r NUMBER_PATTERN="([0-9]+(-[a-ZA-Z0-9-]+)?)" # \5
declare -r FILE_EXT_PATTERN="([a-ZA-Z0-9]{3})" # \6

declare -r PHOTO_FULLNAME_PATTERN="${TITLE_PATTERN}_${DATE_PATTERN}_${TIME_PATTERN}_${CAMERA_PATTERN}_${NUMBER_PATTERN}"

declare -r PHOTO_FILENAME_PATTERN="${TITLE_PATTERN}_${DATE_PATTERN}_${TIME_PATTERN}_${CAMERA_PATTERN}_${NUMBER_PATTERN}\.${FILE_EXT_PATTERN}"

function fullname_from_filename() {
    local -r basename=$(basename "$1")
    echo "${basename%%.*}"
}

function headline_from_photofile() {
    local -r photo_filename=$(basename "$1")
    echo "$photo_filename" | sed -r 's/'"$PHOTO_FILENAME_PATTERN"'/\1 \5/'
}