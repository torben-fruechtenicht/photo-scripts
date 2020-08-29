declare -r ROOTDIR_PATTERN="/.+"
declare -r YEAR_DIR_PATTERN="[0-9]{4}"
declare -r ALBUM_DIR_PATTERN="[^/]+"
declare -r DAY_DIR_PATTERN="[0-9]{4}-[0-9]{2}-[0-9]{2}"

declare -r TITLE_PATTERN="([^_]+)" # \1
declare -r DATE_PATTERN="([0-9]{8})" # \2
declare -r TIME_PATTERN="([0-9]{4})" # \3
declare -r CAMERA_PATTERN="([a-zA-Z0-9-]+)" # \4
declare -r NUMBER_PATTERN="([0-9A-Z]+(-[a-zA-Z0-9-]+)?)" # \5
declare -r FILE_EXT_PATTERN="(\.[a-ZA-Z0-9]{3})+" # \6

declare -r PHOTO_FULLNAME_PATTERN="${TITLE_PATTERN}_${DATE_PATTERN}_${TIME_PATTERN}_${CAMERA_PATTERN}_${NUMBER_PATTERN}"

declare -r PHOTO_FILENAME_PATTERN="${PHOTO_FULLNAME_PATTERN}${FILE_EXT_PATTERN}"

is_original_photofile() ( 
    local -r file=$1
    shopt -s nocasematch

    # TODO check that parent directories of sourcephoto are year/album/date

    [[ -f $file ]] && \
        # TODO use PHOTO_FULLNAME_PATTERN
        [[ $file =~ .+\.(ORF|RAW|JPG|CRW|CR2)$ ]] && \
        ! [[ $file =~ .+/converted/^/+$ ]]
)

albumpath_from_file() {
    local -r file=$1
    local -r pattern="(${ROOTDIR_PATTERN}/${YEAR_DIR_PATTERN}/${ALBUM_DIR_PATTERN})/${DAY_DIR_PATTERN}/(converted/)?${PHOTO_FILENAME_PATTERN}"
    sed -r 's|'"$pattern"'|\1|' <<<"$file"
}

albumname_from_file() {
    local -r file=$1
    local -r pattern="${ROOTDIR_PATTERN}/${YEAR_DIR_PATTERN}/(${ALBUM_DIR_PATTERN})/${DAY_DIR_PATTERN}/(converted/)?${PHOTO_FILENAME_PATTERN}"
    sed -r 's|'"$pattern"'|\1|' <<<"$file"
}

path_relative_to_sourceroot_from_file() {
    local -r file=$1
    local -r pattern="${ROOTDIR_PATTERN}/(${YEAR_DIR_PATTERN}/${ALBUM_DIR_PATTERN}/${DAY_DIR_PATTERN}/(converted/)?${PHOTO_FILENAME_PATTERN})"
    sed -r 's|'"$pattern"'|\1|' <<<"$file"
}

path_relative_to_album_from_file() {
    local -r file=$1
    local -r pattern="${ROOTDIR_PATTERN}/${YEAR_DIR_PATTERN}/${ALBUM_DIR_PATTERN}/(${DAY_DIR_PATTERN}/(converted/)?${PHOTO_FILENAME_PATTERN})"
    sed -r 's|'"$pattern"'|\1|' <<<"$file"
}