function to_import_item() {
    local source_file=$1
    local camera=$2
    local album=$3

    # FIXME check if album is a valid string to be used as a directory name, exit if not
    # FIXME make album a safe directory name if possible

    local source_filename=${source_file##*/}
    source_filename_pattern='([a-zA-Z_]+)_([0-9]{8})_([0-9]{4})-([0-9a-zA-Z]+(-[0-9a-zA-Z]+)?)\.([a-z0-9]{3})'

    local target

    fulldaydate=$(sed -r 's/'"$source_filename_pattern"'/\2/' <<<$source_filename)
    target+="${fulldaydate:0:4}"
    target+="/${album}"
    target+="/${fulldaydate:0:4}-${fulldaydate:4:2}-${fulldaydate:6:2}"
    if [[ $(dirname "$source_file") =~ .*/converted$ ]]; then
        target+="/converted"
    fi

    local title=$(sed -r 's/'"$source_filename_pattern"'/\1/' <<<$source_filename | tr _ -)
    local day=$(sed -r 's/'"$source_filename_pattern"'/\2/' <<<$source_filename)
    local time=$(sed -r 's/'"$source_filename_pattern"'/\3/' <<<$source_filename)
    local number=$(sed -r 's/'"$source_filename_pattern"'/\4/' <<<$source_filename)
    local extension=$(sed -r 's/'"$source_filename_pattern"'/\6/' <<<$source_filename)
    target+="/${title}_${day}_${time}_${camera}_${number}.${extension}"

    echo "$source_file|$target"
}